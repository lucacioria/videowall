# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

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

$cont = null
video_template = null
screenshot_template = null
wall = null

videos = []
current_index = 0

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

display_videos_chunk = ->
  available_area = $(window).width() * $(window).height()
  area = 0
  to_append = []
  while area < available_area and current_index < videos.length

    video = videos[current_index]
    size = get_size video
    area += size.width * size.height

    to_append.push $ screenshot_template
      video_id: video_id video.video_url
      width: size.width
      height: size.height
      class_mod: size.mod
      video_index: current_index

    current_index++

  $cont.append(to_append).masonry 'appended', to_append, true

scroll_check = ->
  if current_index < videos.length and $(window).scrollTop() >= $(document).height() - $(window).height() - 100
    display_videos_chunk()

load_video = ->
  id = $(@).data 'videoid'
  video = videos[id]
  size = get_size video
  $(@).html = video_template
    video_id: video_id video.video_url
    width: size.width
    height: size.height
    class_mod: size.mod

$ ->
  $cont = $ '#container'

  update_cont_size()
  $(window).resize update_cont_size
  $(window).scroll scroll_check
  $('.screenshot').live 'click', load_video

  video_template = _.template $('#video-template').html()
  screenshot_template = _.template $('#screenshot-template').html()

  get_videos (v) ->
    videos = v

    $cont.masonry
      columnWidth: COLUMN_WIDTH
      isResizable: true
    display_videos_chunk()