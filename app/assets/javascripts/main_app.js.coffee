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
$loader = null
video_template = null
screenshot_template = null
wall = null

videos = []
friends = []
current_index = 0
history = null
state_index = 0

build_url = (res) ->
	'/videos/' + res

video_id = (url) ->
  match = url.match /v=([^&#]+)/
  match?[1]

get_videos = (id, cb) ->
  if not cb
    cb = id
    res = 'me'
  else
    res = 'friend/' + id
  $loader.css 'display', 'block'
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
  $loader.css 'display', 'none'

scroll_check = ->
  if current_index < videos.length and $(window).scrollTop() >= $(document).height() - $(window).height() - 100
    $loader.css 'display', 'block'
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

my_videos = (first_load = false) ->
  get_videos (v) ->
    videos = v

    clear_container first_load
    display_videos_chunk()

clear_container = (first_load = false) ->
  current_index = 0
  if not first_load
    $cont.masonry 'destroy'
    $cont.html ''
  $cont.masonry
    columnWidth: COLUMN_WIDTH
    isResizable: true

$ ->
  $cont = $ '#container'
  $loader = $ '.loader'

  update_cont_size()
  $(window).resize update_cont_size
  $(window).scroll scroll_check
  $('.screenshot').live 'click', load_video

  video_template = _.template $('#video-template').html()
  screenshot_template = _.template $('#screenshot-template').html()

  history = History
  history.Adapter.bind window, 'statechange', ->

  my_videos true

  get_friends (f) ->
    friends = f
    $search = $('#search')
    source = (el.name for el in friends)
    console.log source
    $search.autocomplete
      source: source
      source: (request, response) ->
        results = $.ui.autocomplete.filter source, request.term
        response results.slice 0, 10
      focus: (event, ui) ->
        $search.val ui.item.value
        false
      select: (event, ui) ->
        if not ui.item then return
        for el in friends
          if el.name == ui.item.value
            get_videos el.id, (v) ->
              videos = v
              clear_container()
              display_videos_chunk()

            # history.pushState {state:state_index}, '', '/friend/' + ui.item.label
            state_index++
            return false

    $('.right_menu a').click ->
      my_videos()