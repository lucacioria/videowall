# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

displayed = []
videos = []

V_SIZES = [
  {
    mod: 'big'
    width: 475
    height: 267
  }
  {
    mod: 'small'
    width: 230
    height: 129
  }
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
    V_SIZES[1]
  else
    V_SIZES[0]

update_cont_size = ->
  win_width = $(window).width()
  cont_width = win_width / V_SIZES[0].width - win_width % V_SIZES[0].width
  cont_width += V_SIZES[1].width while cont_width + V_SIZES[1].width < win_width

  $('.wrapper').css 'max-width', cont_width + 'px'
  $cont.css 'margin-left', win_width - cont_width + 'px'

$cont = null

$ ->
  $cont = $ '#container'

  update_cont_size()

  video_template = _.template $('#video-template').html()

  get_videos (v) ->
    videos = v
    for video in videos
      size = get_size video
      $cont.append video_template
        video_id: video_id video.video_url
        width: size.width
        height: size.height
        class_mod: size.mod

    wall = new Masonry $cont[0],
      columnWidth: 245
      isResizable: true