class VideosController < ApplicationController
  
  # before_filter :fake_login

  def me
    if user_signed_in? then
      ### videos I like
      videos_i_like = get_videos_i_like()
      update_videos_i_like_in_database(videos_i_like)
      ### videos I posted
      videos_i_posted = get_videos_i_posted()
      update_videos_i_posted_in_database(videos_i_posted)
      ###
      out = []
      require 'youtube_it'
      client = YouTubeIt::Client.new
      current_user.videos.each{ |video|
        video_deleted = false
        begin
          video_youtube_id = video.video_url.scan(/v\=([^\&\#]+)/)[0][0]
          client.video_by video_youtube_id
        rescue
          video_deleted = true
        end
        out << video if not video_deleted
      }
      render json: out.shuffle
    else
      render json: []
    end
  end

  def friend
    if user_signed_in? then
      friend = User.find(:first, :conditions => "uid = #{params[:id]}")
      videos = friend.videos
      render json: (videos.nil? || videos.count == 0) ? [] : videos
    else
      render json: []
    end
  end

  def friends
    if user_signed_in? then
      render json: get_friends
    else
      render json: []
    end
  end

  private

  def get_friends
    rest = Koala::Facebook::API.new(current_user.authentications.first.token)
    rest.graph_call("me/friends")
  end

  def get_videos_i_like
    rest = Koala::Facebook::API.new(current_user.authentications.first.token)
    rest.fql_query("SELECT url FROM url_like WHERE user_id = me() AND strpos(lower(url), 'http://www.youtube.com/') == 0")
  end

  def get_videos_i_posted
    rest = Koala::Facebook::API.new(current_user.authentications.first.token)
    rest.fql_query("SELECT created_time, url FROM link WHERE owner = me() AND strpos(lower(url), 'http://www.youtube.com/') == 0")
  end

  def update_videos_i_like_in_database(videos_i_like)
    videos_i_like.each do |video|
      if Video.find(:first, :conditions  => "video_url = '#{video["url"]}'").nil? then
        v = current_user.videos.new
        v.video_url = video["url"]
        v.video_type = "facebook_like"
        v.save
      end
    end
  end

  def update_videos_i_posted_in_database(videos_i_posted)
    videos_i_posted.each do |video|
      if Video.find(:first, :conditions  => "video_url = '#{video["url"]}'").nil? then
        v = current_user.videos.new
        v.video_url = video["url"]
        v.video_type = "facebook_post"
        v.action_date = Time.at(video["created_time"].to_i)
        v.save
      end
    end
  end

  def fake_login
    sign_in User.find(1)
  end
  
end