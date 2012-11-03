class VideosController < ApplicationController
  
  #before_filter :fake_login

  def index
    if user_signed_in? then
      videos_i_like = get_videos_i_like()
      update_videos_in_database(videos_i_like)
      render json: current_user.videos
    else
      render json: []
    end
  end

  private

  def get_videos_i_like
    rest = Koala::Facebook::API.new(current_user.authentications.first.token)
    rest.fql_query("SELECT url FROM url_like WHERE user_id = me() AND strpos(lower(url), 'http://www.youtube.com/') == 0")
  end

  def update_videos_in_database(videos_i_like)
    videos_i_like.each do |video|
      if Video.find(:first, :conditions  => "video_url = '#{video["url"]}'").nil? then
        v = current_user.videos.new
        v.video_url = video["url"]
        v.video_type = "facebook_like"
        v.save
      end
    end
  end

  def fake_login
    sign_in User.find(1)
  end
  
end