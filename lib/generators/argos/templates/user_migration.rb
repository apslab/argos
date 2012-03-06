class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :uid 
      t.string :first_name 
      t.string :last_name
      t.string :email

      t.timestamps
    end

    add_index :users, :uid, :unique
    add_index :users, :email, :unique
  end

  def self.down
    drop_table :users
  end
end
