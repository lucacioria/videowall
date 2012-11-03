class MainAppController < ApplicationController

	def index

	end

	def prova
		if user_signed_in? then
			@rest = Koala::Facebook::API.new(current_user.authentications.first.token)
			#@likes = @rest.fql_query("SELECT * FROM url_like WHERE user_id = me() AND strpos(lower(url), 'http://www.youtube.com/') == 0")#.map{|x|"<a href='" + x["url"] + "'>" + x["url"] + "</a><br>"}
			@likes = @rest.fql_query("SELECT url FROM url_like WHERE user_id = me() AND strpos(lower(url), 'http://www.youtube.com/') == 0")
		else
			@likes = "NOT SIGNED IN"
		end
	end
	
end
