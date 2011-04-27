class Conversation < ActiveRecord::Base
  include Visitable
  include Subscribable
  include Regionable
  include GeometryForStyle

  has_many :contributions
  has_many :confirmed_contributions, :class_name => 'Contribution',
           :conditions => ['confirmed = ?', true]

  has_many :top_level_contributions
  has_many :subscriptions, :as => :subscribable, :dependent => :destroy
  accepts_nested_attributes_for :top_level_contributions, :allow_destroy => true

  # any person that has made a contribution to the convo
  has_many :participants, :through => :confirmed_contributions,
           :source => :person, :uniq => true,
           :order => "contributions.created_at ASC"

  has_and_belongs_to_many :issues
  has_one :survey, :as => :surveyable
  belongs_to :person, :foreign_key => "owner"

  attr_accessor :rejected_contributions

  has_attached_file :image,
    :styles => {
       :normal => "480x300#",
       :panel => "198x130#"},
    :storage => :s3,
    :s3_credentials => S3Config.credential_file,
    :path => IMAGE_ATTACHMENT_PATH,
    :default_url => '/images/convo_img_:style.gif'

  validates :owner, :must_be_logged_in => true
  validates_length_of :contributions, :is => 1, :on => :create, :if => :from_community?,
    :message => "Please get the ball rolling with the first comment, question, or contribution of some sort."
  validates_length_of :issues, :minimum => 1, :on => :create,
    :message => "Please choose at least one issue that best relates to your conversation."

  validates_presence_of :owner
  validates_presence_of :title, :message => "Please choose a title for your conversation."
  validates_presence_of :summary, :message => "Please give us a short summary."
  validates_presence_of :zip_code, :message => "Please give us a zip code for a little geographic context."

  after_create :set_initial_position
  before_destroy :destroy_root_contributions # since non-root contributions will be destroyed internally be awesome_nested_set

  has_friendly_id :title, :use_slug => true, :strip_non_ascii => true

  scope :latest_updated, :order => 'updated_at DESC'
  scope :latest_created, :order => 'created_at DESC'

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
      where("contributions.type != 'TopLevelContribution'").
      where("contributions.created_at > ?", Time.now - 60.days).
      group('conversations.id').
      order('count_all DESC, max_contributions_created_at DESC')
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
      conversation.update_attribute(:position, i)
    end

    others.each_with_index do |conversation, i|
      conversation.update_attribute(:position, i + staff_picks.length)
    end
  end

  def user_generated?
    from_community
  end

  # Define our own method for allowing fields_for :contribution, rather
  # than using accepts_nested_association :contributions.
  # We need to use our custom Contribution builder to create contributions
  # of only allowed types.
  def contributions_attributes=(attributes)
    self.rejected_contributions = []
    attributes.each_value { |attr|
      attr.merge!(:item => self)
      if attr[:type]  && attr[:type].constantize == EmbedlyContribution
        attr_hash = {contribution: attr}
        embedly = EmbedlyService.new
        embedly.fetch_and_merge_params!(attr_hash)
        attr.merge!(attr_hash[:contribution])
      end
      # Rather than set contribution.person over and over, 
      # it will now be set from contribution#set_person_from_item before_validation hook
      contribution = Contribution.new_confirmed_node_level_contribution(attr, nil)
      if contribution.valid?
        self.contributions << contribution
      else
        self.rejected_contributions << contribution
      end
    }
  end

  def sort
    max_position = Conversation.where('staff_pick = true').maximum('position')
    update_attribute(:position, max_position + 1) if max_position
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

  protected

  def destroy_root_contributions
    # Make sure to delete root contributions in descending order of rgt
    # value. Otherwise lft/rgt values will become corrupted due to the
    # fact that the root objects don't get refreshed with adjusted
    # lft/rgt values after previous roots are destroyed, while the
    # decendants will be refreshed with new adjusted lft/rgt values and
    # thus be shifted out of the lft/rgt ancestor bounds of the stale
    # root objects in the collect block below.
    self.contributions.roots.sort_by(&:rgt).reverse.collect(&:destroy)
  end

end
