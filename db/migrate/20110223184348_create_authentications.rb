class CreateAuthentications < ActiveRecord::Migration
  def self.up
    create_table :authentications do |t|
      t.string :provider
      t.string :uid
      t.string :token
      t.string :secret
      t.integer :person_id

      t.timestamps
    end
    add_index :authentications, :provider
    add_index :authentications, :uid
    add_index :authentications, :person_id
  end

  def self.down
    remove_index :authentications, :person_id
    remove_index :authentications, :uid
    remove_index :authentications, :provider
    
    drop_table :authentications
  end
end