require 'parent_validator'

class Contribution < ActiveRecord::Base
  include Rateable
  include Visitable
  include TopItemable
  acts_as_nested_set
  
  ALL_TYPES = ["Answer","AttachedFile","Comment","EmbeddedSnippet","Link",
               "Question","SuggestedAction", "PAContribution"]
  
  belongs_to :person, :foreign_key => "owner"
  belongs_to :conversation
  belongs_to :issue
  
  validates_with ContributionValidator
  validates :item, :presence=>true 
  validates :person, :must_be_logged_in => true
  validates_associated :conversation, :parent, :person
  
  scope :most_recent, {:order => 'created_at DESC'}
  scope :not_top_level, where("type != 'TopLevelContribution'")
  scope :without_parent, where(:parent_id => nil)
    
  def self.new_node_level_contribution(params, person)
    model, params = setup_node_level_contribution(params,person)
    model.new(params)
  end
  
  def self.create_node_level_contribution(params, person)
    model, params = setup_node_level_contribution(params,person)
    model.create(params)
  end

  def item=(item)
    if item.is_a?(Conversation)
      self.conversation = item
    elsif item.is_a?(Issue)
      self.issue = item
    end
  end
 
  def item
    self.conversation || self.issue
  end

  # Is this contribution an Image? Default to false, override in
  # subclasses
  def is_image?
    false
  end
  
  protected
  
  def self.setup_node_level_contribution(params,person)
    model = params.delete(:type).constantize
    # could probably do this much cleaner, but still need to sanitize this for now
    raise(ArgumentError, "not a valid node-level Contribution type") unless ALL_TYPES.include?(model.to_s)
    params.merge!({:person => person})
    return model,params
  end

end
