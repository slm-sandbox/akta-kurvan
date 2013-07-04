# Polyfills
requestAnimationFrame = window.requestAnimationFrame || window.mozRequestAnimationFrame ||
  window.webkitRequestAnimationFrame || window.msRequestAnimationFrame;
window.requestAnimationFrame = requestAnimationFrame;


# State variables
state =
  players: {}
  playerId: null

# "Cached" DOM references
field, svg = null

class Player
  constructor: (element) ->
    @toDraw = []
    @pathElements = [element]


socket = io.connect 'http://localhost:8080'

socket.on 'players', (players) ->
  if not state.players[Object.keys(players)[0]]
    initGame(players)

  for id, player of players
    players[id].toDraw.push {x: player.x, y: player.y, trailActive: player.trailActive}

socket.on 'reset', (data) ->
  svg.innerHTML = ''
  svg.height = data.maxHeight
  svg.width  = data.maxWidth
  state.players = []

join = (userName) ->
  socket.emit 'join', {userName: userName}, (id) ->
    state.playerId = id

turnLeft = ->
  socket.emit 'left'

turnRight = ->
  socket.emit 'right'

stopTurning = ->
  socket.emit 'stopTurning'


initGame = (players) ->
  for id, player of players
    el = document.createElement('path')
    el.id = id
    el.d = "M #{player.x} #{player.y}"
    svg.appendChild el
    state.players[id] = new Player el


reset = ->



requestAnimationFrame ->
  for id, player of state.players
    el = player.pathElements[player.pathElements.length - 1]
    toDraw = player.toDraw
    player.toDraw = []
    for point in toDraw
      el.d += " L #{point.x} #{point.y}"



onReady = ->
  field = document.getElementById 'field'
  svg = document.getElementById 'svg'

document.addEvenetListener 'DOMContentLoaded', () ->
  onReady()
  document.removeEventListener 'DOMContentLoaded', arguments.callee
