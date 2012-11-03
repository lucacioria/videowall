class MainAppController < ApplicationController

	before_filter :fake_login

	def index

	end

	def prova
		if user_signed_in? then
			@rest = Koala::Facebook::API.new(current_user.authentications.first.token)
			@likes = @rest.fql_query("SELECT url FROM url_like WHERE user_id = me() AND strpos(lower(url), 'http://www.youtube.com/') == 0")
		end
	end

	def fake_login
	    sign_in User.find(1)
	end
	
end
