class Oauth::Nonce < ActiveRecord::Base
  set_table_name 'oauth_nonces'
  
  validates_presence_of :nonce, :timestamp
  validates_uniqueness_of :nonce, :scope => :timestamp

  
  # TODO: Ver de que modo se va a limpiar esta tabla periodicamente (varias veces al día)
  def self.remember(nonce, timestamp)
    oauth_nonce = create(:nonce => nonce, :timestamp => timestamp)
    return false if oauth_nonce.new_record?
    oauth_nonce
  end
end
