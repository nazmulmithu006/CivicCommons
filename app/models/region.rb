class Region < ActiveRecord::Base

  before_save :create_zip_codes
  
  has_many :zip_codes
  accepts_nested_attributes_for :zip_codes

  has_attached_file :image,
    :styles => {:normal => "300x200>"},
      :storage => :s3,
      :s3_credentials => S3Config.credential_file,
      :path => ":attachment/region/:id/:style/:filename"
  validates_attachment_presence :image
  validates_attachment_content_type :image,
                                    :content_type => /image\/*/,
                                    :message => "Not a valid image file."


  def self.default_name
    "National"
  end

  def self.default
    rv = new(:name=>self.default_name)
    rv.id = 0
    rv
  end

  def self.find_by_zip_code(zip_code)
    Region.joins(:zip_codes).where("zip_codes.zip_code = #{zip_code}").first
  end

  def issues
    Issue.where(where_clause)
  end

  def people
    Person.includes(:authentications).where(where_clause)
  end

  def conversations(page = 1)
    Conversation.where(where_clause).paginate(:page=>page, :per_page=>6)
  end

  def where_clause
    rv = "zip_code = 'all' or zip_code NOT IN (SELECT DISTINCT zip_code FROM zip_codes)"
    unless self.default?
      zipcodes = zip_code_string(",")
      zipcodes = zipcodes.length > 0 ? "'all',#{zipcodes}" : "'all'"
      rv = "zip_code IN (#{zipcodes})"
    end
    rv
  end
                                    
  def default?
    self.name == Region.default_name
  end

  def zip_code_string(delimiter = "\n")
    self.zip_codes.collect{|c| c.zip_code}.join(delimiter)
  end

  def zip_code_string=(val)
    @zip_code_string = val
    create_zip_codes
  end

  def create_zip_codes
    self.zip_codes = [] if self.zip_codes.nil?
    self.zip_codes.clear
    @zip_code_string ||= ""
    @zip_code_string.split("\n").each do |c|
      self.zip_codes << ZipCode.find_or_create_by_zip_code(c.strip)
    end
  end
end
