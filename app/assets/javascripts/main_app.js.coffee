# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

displayed = []
videos = []

COLUMN_WIDTH = 245

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
	'/videos'

video_id = (url) ->
  match = url.match /\?v=([^&]+)/
  match?[1]

get_videos = (cb) ->
	$.getJSON build_url('videos'), (data) ->
    cb data

get_size = (video) ->
  if video.starred or Math.random() > 0.80
    V_SIZES[0]
  else
    V_SIZES[1]

update_cont_size = ->
  win_width = $(document).width()
  cont_width = win_width - win_width % COLUMN_WIDTH

  $('.wrapper').css 'max-width', cont_width + 'px'

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
      columnWidth: COLUMN_WIDTH
      isResizable: true