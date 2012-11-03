Rails.application.config.middleware.use OmniAuth::Builder do
  # The following is for facebook
  provider :facebook, 491912824174916, 'bb146bc65ab492ceabeb379813428700', {:scope => 'email, read_stream, read_friendlists, user_likes, user_status, friends_likes, friends_status'}
 
  # If you want to also configure for additional login services, they would be configured here.
end