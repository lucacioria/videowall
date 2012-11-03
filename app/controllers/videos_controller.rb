class VideosController < ApplicationController
  
  #before_filter :fake_login

  before_filter :setup_youtube
  def me
    if user_signed_in? then
      ### videos I like
      videos_i_like = get_videos_i_like()
      update_videos_i_like_in_database(videos_i_like)
      ### videos I posted
      videos_i_posted = get_videos_i_posted()
      update_videos_i_posted_in_database(videos_i_posted)
      ###
      out = current_user.videos.find(:all, :conditions  => "deleted = false")
      out = sort_by_dateish(out)
      render json: out
    else
      render json: []
    end
  end

  def friend
    if user_signed_in? then
      friend = User.find(:first, :conditions => "uid = #{params[:id]}")
      if friend.nil? then
        render json: []
      else
        videos = friend.videos.find(:all, :conditions  => "deleted = false")
        render json: (videos.nil? || videos.count == 0) ? [] : sort_by_dateish(videos)
      end
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

  def sort_by_dateish(list)
    with_date = list.find_all{|x| x[:action_date].nil? == false}.sort_by{|x|x[:action_date]}
    without_date = list.find_all{|x| x[:action_date].nil?}.reverse
    map_factor = without_date.count.to_f / (with_date.count+1)
    (0...without_date.count).each {|i|
      with_date.insert([i * map_factor, with_date.count].min , without_date[i])
    }
    with_date.reverse
  end

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
        v.deleted = video_deleted_on_youtube video["url"]
        v.save
      end
    end
  end

  def setup_youtube
      require 'youtube_it'
      @youtube = YouTubeIt::Client.new
  end

  def video_deleted_on_youtube(url)
    video_deleted = false
    begin
      video_youtube_id = url.scan(/v\=([^\&\#]+)/)[0][0]
      @youtube.video_by video_youtube_id
    rescue
      video_deleted = true
    end
    video_deleted || Video.video_blacklisted(url)
  end

  def update_videos_i_posted_in_database(videos_i_posted)
    videos_i_posted.each do |video|
      if Video.find(:first, :conditions  => "video_url = '#{video["url"]}'").nil? then
        v = current_user.videos.new
        v.video_url = video["url"]
        v.video_type = "facebook_post"
        v.action_date = Time.at(video["created_time"].to_i)
        v.deleted = video_deleted_on_youtube video["url"]
        v.save
      end
    end
  end

  def fake_login
    sign_in User.find(1)
  end
  
end