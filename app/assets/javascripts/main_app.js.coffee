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
friends = []
current_index = 0

build_url = (res) ->
	'/videos/' + res

video_id = (url) ->
  match = url.match /\?v=([^&]+)/
  match?[1]

get_videos = (id, cb) ->
  if not cb
    cb = id
    res = 'me'
  else
    res = 'friend/' + id
  $.getJSON build_url(res), (data) ->
    cb data

get_friends = (cb) ->
  $.getJSON '/videos/friends', cb

get_size = (video) ->
  if video.starred or Math.random() > 0.90
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
  clear_cont = current_index == 0
  while area < available_area and current_index < videos.length

    video = videos[current_index]
    size = get_size video
    area += size.width * size.height

    to_append.push screenshot_template
      video_id: video_id video.video_url
      width: size.width
      height: size.height
      class_mod: size.mod
      video_index: current_index
      video_size: JSON.stringify size

    current_index++

  to_append = $ to_append.join ''
  if clear_cont
    $cont.html ''
  $cont.append(to_append).masonry 'appended', to_append, true

scroll_check = ->
  if current_index < videos.length and $(window).scrollTop() >= $(document).height() - $(window).height() - 100
    display_videos_chunk()

load_video = ->
  id = $(@).data 'videoid'
  video = videos[id]
  size = $(@).data 'videosize'
  $(@).html video_template
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

  get_friends (f) ->
    friends = f
    $search = $('#search')
    $search.autocomplete
      source: ({value: el.id, label: el.name} for el in friends)
      focus: (event, ui) ->
        $search.val ui.item.label
        false
      selected: (event, ui) ->
        $search.val ui.item.label
        false
      change: (event, ui) ->
        $search.val ui.item.label
        get_videos ui.item.value, (v) ->
          current_index = 0
          $cont.masonry 'destroy'
          $cont.masonry
            columnWidth: COLUMN_WIDTH
            isResizable: true
          display_videos_chunk()
        false

