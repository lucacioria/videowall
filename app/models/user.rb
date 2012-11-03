class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

	has_many :authentications, :dependent => :delete_all
	has_many :videos

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :firstname, :lastname, :name, :username, :uid

    def apply_omniauth(auth)
	  # In previous omniauth, 'user_info' was used in place of 'raw_info'
	  self.email = auth['extra']['raw_info']['email']
	  self.uid = auth['uid']
	  # Again, saving token is optional. If you haven't created the column in authentications table, this will fail
	  authentications.build(:provider => auth['provider'], :uid => auth['uid'], :token => auth['credentials']['token'])
	end

	def user_already_has_video?(url)
	  	return videos.where("url = " + url).any? 
	end

end
