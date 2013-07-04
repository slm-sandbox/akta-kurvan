# Polyfills
requestAnimationFrame = window.requestAnimationFrame || window.mozRequestAnimationFrame ||
  window.webkitRequestAnimationFrame || window.msRequestAnimationFrame;
window.requestAnimationFrame = requestAnimationFrame;


# State variables
state =
  players: {}
  playerId: null

# "Cached" DOM references
field = svg = null

class Player
  constructor: (element) ->
    @toDraw = []
    @pathElements = [element]


handlers =
  players: (players) ->
    console.log 'Got players'
    if not state.players[Object.keys(players)[0]]
      initGame(players)

    for id, player of players
      players[id].toDraw.push {x: player.x, y: player.y, trailActive: player.trailActive}

socket = io.connect 'http://localhost:8080'
socket.on 'connect', ->
  console.log "Connected"

socket.on 'players', (players) ->
  console.log 'Got players'
  for id, player of players
    players[id].toDraw.push {x: player.x, y: player.y, trailActive: player.trailActive}

socket.on 'newGame', (players) ->
  console.log 'Got new game'
  initGame(players)

  svg.innerHTML = ''
  svg.height = data.maxHeight
  svg.width  = data.maxWidth
  state.players = []

join = (userName) ->
  socket.emit 'join', {userName: userName}, (id) ->
    console.log 'Joined'
    state.playerId = id

join("test")

controls =
  left: ->
    socket.emit 'left'

  right: ->
    socket.emit 'right'

  stop: ->
    socket.emit 'stopTurning'


initGame = (players) ->
  console.log 'Init game'
  for id, player of players
    el = document.createElementNS svg , "path"
    el.id = id
    el.d = "M #{player.x} #{player.y}"

    if id is state.playerId
      el.className = 'own'
    else
      el.className = 'enemy'

    svg.appendChild el
    state.players[id] = new Player el


requestAnimationFrame ->
  console.log 'Rendering'
  for id, player of state.players
    el = player.pathElements[player.pathElements.length - 1]
    toDraw = player.toDraw
    player.toDraw = []
    for point in toDraw
      el.d += " L #{point.x} #{point.y}"

onReady = ->
  console.log 'Document ready'
  field = document.getElementById 'field'
  svg = document.getElementById 'svg'

document.addEventListener 'DOMContentLoaded', () ->
  onReady()
  document.removeEventListener 'DOMContentLoaded', arguments.callee
