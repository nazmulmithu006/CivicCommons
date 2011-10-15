class Issue < ActiveRecord::Base
  include Visitable
  include Subscribable
  include Regionable
  include GeometryForStyle
  include HomepageFeaturable

  searchable :ignore_attribute_changes_of => [ :total_visits, :recent_visits, :last_visit_date, :updated_at, :recent_rating ] do
    text :name, :boost => 3, :default_boost => 3
    text :summary, :stored => true, :boost => 2, :default_boost => 2
  end

  ALL_TYPES = ['Issue', 'ManagedIssue']

  belongs_to :person

  has_and_belongs_to_many :conversations
  has_and_belongs_to_many :topics
  # Contributions directly related to this Issue
  has_many :contributions
  has_many :suggested_actions
  has_many :surveys, :as => :surveyable
  has_many :votes, :as => :surveyable, :class_name => 'Survey', :conditions => {:type => 'Vote'}
  has_many(:media_contributions, :class_name => "Contribution",
           :conditions => {:type => ['EmbeddedSnippet', 'Link', 'AttachedFile']})

  has_many :subscriptions, :as => :subscribable, :dependent => :destroy

  # Anyone who has contributed directly to the issue via a contribution
  has_many(:participants,
           :through => :contributions,
           :source => :person,
           :uniq => true)

  has_attached_file(:image,
                    :styles => {
                      :normal => "480x300#",
                      :panel => "198x130#" },
                    :storage => :s3,
                    :s3_credentials => S3Config.credential_file,
                    :path => IMAGE_ATTACHMENT_PATH)
  validates_attachment_content_type :image,
                                    :content_type => /image\/*/,
                                    :message => "Not a valid image file."

  has_friendly_id :name, :use_slug => true, :strip_non_ascii => true

  before_create :assign_position

  validates :name, :presence => true, :length => { :minimum => 5 }
  validates_uniqueness_of :name
  validates_attachment_presence :image
  
  scope(:most_active, :select =>
        'count(1) as contribution_count, issues.*',
        :joins => [:contributions],
        :group => "issues.id",
        :order => 'contribution_count DESC')
  scope :custom_order, {:order => 'position ASC'}
  scope :most_recent, {:order => 'created_at DESC'}
  scope :most_recent_update, {:order => 'updated_at DESC'}
  scope :alphabetical, {:order => 'name ASC'}
  scope :sort, lambda { |sort_type|
      case sort_type
      when 'most_recent'
        most_recent
      when 'alphabetical'
        alphabetical
      when 'most_recent_update'
        most_recent_update
      when 'most_active'
        most_active
      else
        custom_order
      end
    }

  def self.random
    if (c = count) != 0
      find(:first, :offset =>rand(c))
    end
  end

  def self.sample(count=1)
    result = []

    until result.size == count do
      random_issue = self.random
      result << random_issue if !result.include?(random_issue)
    end
    result
  end

  def self.assign_positions
    non_nil_positions = Issue.where('position IS NOT NULL').order('position ASC, id ASC')
    nil_positions = Issue.where('position IS NULL').order('position ASC, id ASC')

    non_nil_positions.each_with_index do |issue, i|
      issue.update_attribute(:position, i)
    end
    nil_positions.each_with_index do |issue, i|
      issue.update_attribute(:position, i + non_nil_positions.size)
    end
  end

  def self.set_position(current_position, next_position, previous_position)
    if previous_position.nil?
      self.update_positions(current_position, 0, next_position)
    elsif next_position.nil?
      self.update_positions(current_position, Issue.maximum('position') + 2, previous_position)
    elsif next_position > previous_position
      self.update_positions(current_position, previous_position + 1, next_position)
    elsif next_position < previous_position
      self.update_positions(current_position, next_position + 1, previous_position)
    end
    Issue.assign_positions
  end

  def self.top_issues
    Issue.all.sort_by do |issue|
      issue.activity_weight
    end
  end

  def activity_weight
    visits = self.visits.count
    contributions = self.contributions.count

    @activity_weight = visits + contributions
  end

  def conversation_comments
    Contribution.joins(:conversation).where({:conversations => {:id => self.conversation_ids}})
  end

  private

  def self.update_positions(current, new_index, comparison)
    current_issue = Issue.find_by_position(current)
    Issue.where('position >= ?', comparison).each do |issue|
      issue.position += 1
      issue.save
    end
    current_issue.position = new_index
    current_issue.save
  end

  def assign_position
    if self.position.nil?
      self.position = Issue.maximum('position') ? Issue.maximum('position') + 1 : 0
    end
  end

  define_method(:title) do
    name
  end

end
