class CreateOauthNonces < ActiveRecord::Migration
  def self.up
    create_table :oauth_nonces do |t|
      t.string :nonce, :limit => 8 
      t.integer :timestamp
      t.datetime :created_at
    end

    add_index :oauth_nonces, [:nonce, :timestamp], :unique
  end

  def self.down
    drop_table :oauth_nonces
  end
end
