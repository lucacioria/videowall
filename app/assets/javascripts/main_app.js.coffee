# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

displayed = []
videos = []

V_SIZES = [
  {
    width: 475
    height: 267
  }
  {
    width: 230
    height: 129
  }
]

V_MOD = [
  'big'
  'small'
]

build_url = (res) ->
	'/videos.json'

video_id = (url) ->
  match = url.match /\?v=([^&]+)/
  match?[1]

get_videos = (cb) ->
	$.getJSON build_url('videos'), (data) ->
    cb data

get_size = (video) ->
  if video.video_type is 'facebook_like'
    size: V_SIZES[1]
    mod: V_MOD[1]
  else
    size: V_SIZES[0]
    mod: V_MOD[0]

$ ->
  video_template = _.template $('#video-template').html()

  $cont = $ '#container'

  get_videos (v) ->
    videos = v
    for video in videos
      s = get_size video
      $cont.append video_template
        video_id: video_id video.video_url
        width: s.size.width
        height: s.size.height
        class_mod: s.mod

    wall = new Masonry $cont[0],
      columnWidth: 245
      isResizable: true
