class Video < ActiveRecord::Base
  attr_accessible :action_date, :hidden, :starred, :type, :url

  belongs_to :user

  def self.video_blacklisted(url)
  	return [].include? url
  end
end
