class MainAppController < ApplicationController

	# before_filter :fake_login

	def index
		if not user_signed_in? then
			redirect_to '/main_app/login'
		end
	end

	def login

	end

	def fake_login
	    sign_in User.find(1)
	end
	
end
