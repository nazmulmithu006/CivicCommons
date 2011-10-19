class Conversation < ActiveRecord::Base
  include Visitable
  include Subscribable
  include Regionable
  include GeometryForStyle
  include HomepageFeaturable

  searchable :ignore_attribute_changes_of => [ :total_visits, :recent_visits, :last_visit_date, :updated_at, :recent_rating ] do
    text :title, :boost => 3, :default_boost => 3
    text :summary, :stored => true, :boost => 2, :default_boost => 2
  end

  has_many :contributions, :dependent => :destroy
  has_many :confirmed_contributions, :class_name => 'Contribution',
           :conditions => ['confirmed = ?', true]
  accepts_nested_attributes_for :contributions, :allow_destroy => true

  has_many :subscriptions, :as => :subscribable, :dependent => :destroy

  def top_level_contributions
    Contribution.where(:conversation_id => self.id, :top_level_contribution => true)
  end

  # any person that has made a contribution to the convo
  has_many :participants, :through => :confirmed_contributions,
           :source => :person, :uniq => true,
           :order => "contributions.created_at ASC"

  has_and_belongs_to_many :issues
  has_one :survey, :as => :surveyable
  belongs_to :person, :foreign_key => "owner"

  has_attached_file :image,
    :styles => {
       :normal => "480x300#",
       :panel => "198x130#"},
    :storage => :s3,
    :s3_credentials => S3Config.credential_file,
    :path => IMAGE_ATTACHMENT_PATH,
    :default_url => '/images/convo_img_:style.gif'
  validates_attachment_content_type :image,
                                    :content_type => /image\/*/,
                                    :message => "Not a valid image file."
  validates :owner, :must_be_logged_in => true
  validates_length_of :contributions, :is => 1, :on => :create, :if => :from_community?,
    :message => "Please get the ball rolling with the first comment, question, or contribution of some sort."
  validates_length_of :issues, :minimum => 1, :on => :create,
    :message => "Please choose at least one issue that best relates to your conversation."

  validates_presence_of :owner
  validates_presence_of :title, :message => "Please choose a title for your conversation."
  validates_presence_of :summary, :message => "Please give us a short summary."
  validates_presence_of :zip_code, :message => "Please give us a zip code for a little geographic context."

  after_create :set_initial_position, :subscribe_creator

  has_friendly_id :title, :use_slug => true, :strip_non_ascii => true

  scope :latest_updated, :order => 'updated_at DESC'
  scope :latest_created, where(:exclude_from_most_recent => false).order('created_at DESC')

  def self.available_filters
    {
      :recommended => :recommended,
      :active => :most_active,
      :popular => :get_top_visited,
      :recent => :latest_created
    }
  end

  def self.available_filter_names
    available_filters.keys.collect(&:to_s)
  end

  def self.most_active
    Conversation.select('conversations.*, COUNT(*) AS count_all, MAX(contributions.created_at) AS max_contributions_created_at').
      joins(:contributions).
      where("contributions.top_level_contribution = 0").
      where("contributions.created_at > ?", Time.now - 60.days).
      group('conversations.id').
      order('count_all DESC, max_contributions_created_at DESC')
  end

  def self.random_active(select=2, limit=4)
    limit = select if select > limit

    actives = Conversation.most_active.limit(limit)
    actives.sample(select)
  end

  def self.random_recommended(select=1)
    r = Conversation.recommended
    r.sample(select)
  end

  def self.recommended
    Conversation.where('staff_pick = true').order('position ASC')
  end

  def self.filtered(filter)
    raise "Undefined Filter :#{filter}" unless available_filter_names.include?(filter)
    scoped & self.send(available_filters[filter.to_sym])
  end

  def self.sort
    conversations = Conversation.order('staff_pick DESC, position ASC, id ASC')
    staff_picks = conversations.select { |c| c.staff_pick? }
    others = conversations - staff_picks

    staff_picks.each_with_index do |conversation, i|
      Conversation.where('id = ?', conversation.id).update_all(position: i)
    end

    staff_picks_length = staff_picks.length
    others.each_with_index do |conversation, i|
      Conversation.where('id = ?', conversation.id).update_all(position: i + staff_picks_length)
    end
  end

  def user_generated?
    from_community
  end

  def sort
    max_position = Conversation.where('staff_pick = true').maximum('position')
    Conversation.where('id = ?', self.id).update_all(position: max_position + 1) if max_position
    Conversation.sort
  end

  def staff_pick?
    staff_pick
  end

  # Return a comma-and-space-delimited list of the Issues
  # relevant to this Conversation, e.g., "Jobs, Sports, Religion"
  def issues_text
    if issues.any?
       issues.map(&:name).join(", ")
    else
      "No issues yet"
    end
  end


  # Original plan: single Moderator per Conversation.
  # New plan: Zero or more Guides per Conversation.
  # validates :moderator, :presence => :true

  def guides_text
    if (guides.count > 0)
      guides.join(", ")
    else
      "No Guides yet"
    end
  end

  def start_month_text
    if started_at.nil?
      "?"
    else
      started_at.strftime("%B")
    end
  end

  def start_day
    if started_at.nil?
      "?"
    else
      started_at.mday
    end
  end

  def set_initial_position
    max = Conversation.maximum(:position)
    if max
     self.update_attribute(:position, max + 1)
    else
      self.update_attribute(:position, 0)
    end
  end

  def subscribe_creator
    Subscription.create_unless_exists(person, self)
  end

end
