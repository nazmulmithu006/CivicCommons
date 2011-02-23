class Authentication < ActiveRecord::Base
  belongs_to :person
  validates_presence_of :uid, :provider, :person_id
  validates_uniqueness_of :uid, :scope => :provider
end
