# The user include:
# 
# - uid
# - first_name
# - last_name
# - email
#
class User < ActiveRecord::Base 

  validates_presence_of :email, :uid

end
