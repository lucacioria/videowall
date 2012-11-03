class Video < ActiveRecord::Base
  attr_accessible :action_date, :hidden, :starred, :type, :url
end
