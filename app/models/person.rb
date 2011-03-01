class Person < ActiveRecord::Base

  include Regionable
  include GeometryForStyle
  include Marketable

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable,
         :omniauthable

  attr_accessor :organization_name, :send_welcome

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :first_name, :last_name, :email, :password, :password_confirmation, :bio, :top, :zip_code, :admin, :validated,
                  :avatar

  has_one :facebook_authentication, :class_name => 'Authentication', :conditions => {:provider => 'facebook'}
  has_many :authentications, :dependent => :destroy
  has_many :contributions, :foreign_key => 'owner', :uniq => true
  has_many :ratings
  has_many :subscriptions
  has_and_belongs_to_many :conversations, :join_table => 'conversations_guides', :foreign_key => :guide_id

  has_many :contributed_conversations, :through => :contributions, :source => :conversation, :uniq => true
  has_many :contributed_issues, :through => :contributions, :source => :issue, :uniq => true

  validates_length_of :email, :within => 6..255, :too_long => "please use a shorter email address", :too_short => "please use a longer email address"
  validates_length_of :zip_code, :within => (5..10), :allow_empty => false, :allow_nil => false
  validates_presence_of :name

  # Ensure format of salt
  # Commented out because devise 1.2.RC doesn't store password_salt column anymore, if it uses bcrypt
  # validates_with PasswordSaltValidator 

  has_attached_file :avatar,
    :styles => {
      :small => "20x20#",
      :medium => "40x40#",
      :standard => "70x70#",
      :large => "185x185#"},
    :storage => :s3,
    :s3_credentials => S3Config.credential_file,
    :default_url => '/images/avatar_70.gif',
    :path => ":attachment/:id/:style/:filename"

  validates_attachment_content_type :avatar,
                                    :content_type => %w(image/jpeg image/gif image/png image/jpg image/x-png image/pjpeg),
                                    :message => "Not a valid image file."
  process_in_background :avatar

  def avatar_exists
    self.avatar.exists?
  end

  scope :participants_of_issue, lambda{ |issue|
      joins(:conversations => :issues).where(['issue_id = ?',issue.id]).select('DISTINCT(people.id),people.*') if issue
    }

  scope :real_accounts, where("proxy is not true")
  scope :proxy_accounts, where(:proxy => true)
  scope :confirmed_accounts, where("confirmed_at is not null")
  scope :unconfirmed_accounts, where(:confirmed_at => nil)

  after_create :notify_civic_commons
  before_save :check_to_send_welcome_email
  after_save :send_welcome_email, :if => :send_welcome?


  def newly_confirmed?
    confirmed_at_changed? && confirmed_at_was.blank? && !confirmed_at.blank?
  end

  def check_to_send_welcome_email
    @send_welcome = true if newly_confirmed?
  end

  def avatar_width_for_style(style)
    geometry_for_style(style, :avatar).width.to_i
  end

  def avatar_height_for_style(style)
    geometry_for_style(style, :avatar).height.to_i
  end
  
  def name=(value)
    @name = value
    self.first_name, self.last_name = self.class.parse_name(value)
  end

  def name
    @name ||= ("%s %s" % [self.first_name, self.last_name]).strip
  end

  def notify_civic_commons
    Notifier.new_registration_notification(self).deliver
  end

  def send_welcome?
    @send_welcome
  end

  def send_welcome_email
    Notifier.welcome(self).deliver
    @send_welcome = false
  end

  def self.find_all_by_name(name)
    first, last = parse_name(name)
    where(:first_name => first, :last_name => last)
  end

  # Takes a full name and return an array of first and last name
  # Examples
  #  "Wendy" => ["Wendy", ""]
  #  "Wendy Smith" => ["Wendy", "Smith"]
  #  "Wendy van Buren" => ["Wendy", "van Buren"]
  #
  def self.parse_name(name)
    first, *last = name.split(' ')
    last = last.try(:join, " ") || ""
    return first, last
  end

  def create_proxy
    self.email = (first_name + last_name).gsub(/['\s]/,'').downcase + "@example.com"
    self.password = 'p4s$w0Rd'
    self.proxy = true
  end

  def subscriptions_include?(subscribable)
    subscriptions.map(&:subscribable).include?(subscribable)
  end

  def avatar_path(style='')
    self.avatar.path(style)
  end

  # Implement Marketable method
  def is_marketable?
    return false if skip_email_marketing

    newly_confirmed? ? true : false
  end
  
  def facebook_authenticated?
    !facebook_authentication.blank?
  end
  
  def link_with_facebook(authentication)
    ActiveRecord::Base.transaction do
      self.facebook_authentication = authentication  
      self.encrypted_password = ''
      save
    end
  end
  
  # Overiding Devise::Models::DatabaseAuthenticatable
  # due to needing to set encrypted_password to blank, so that it doesn't error out when it is set to nil
  def valid_password?(password)
    encrypted_password.blank? ? false : super
  end
  
  # If this account has been linked to facebook auth, then password is not required
  def password_required? 
    facebook_authenticated? ? false : super
  end
  


# Implement Marketable method
  def subscribe_to_marketing_email
    h = Hominid::Base.new(api_key: Civiccommons::Config.mailer_api_token)
    h.delay.subscribe(Civiccommons::Config.mailer_list, email, {:FNAME => first_name, :LNAME => last_name}, {:email_type => 'html'})
    Rails.logger.info("Success. Added mailing list subscription of #{name} to queue.")
  end

protected

  def password_required?
    !persisted? || password.present? || password_confirmation.present?
  end

end
