# Polyfills
requestAnimationFrame = window.requestAnimationFrame || window.mozRequestAnimationFrame ||
  window.webkitRequestAnimationFrame || window.msRequestAnimationFrame;
window.requestAnimationFrame = requestAnimationFrame;


# State variables
window.state =
  players: {}
  playerId: null

# "Cached" DOM references
window.field = window.svg = null

class Player
  constructor: (element) ->
    @toDraw = []
    @pathElements = [element]


window.handlers =
  players: (players) ->
    console.log 'Got players'
    if not state.players[Object.keys(players)[0]]
      initGame(players)

    for id, player of players
      state.players[id].toDraw.push {x: player.x, y: player.y, trailActive: player.trailActive}

socket = io.connect 'http://localhost:8080'
socket.on 'connect', ->
  console.log "Connected"

socket.on 'newGame', (data) ->
  console.log 'Got new game'
  initGame(data.players)

  while svg.lastChild
      svg.removeChild(svg.lastChild);

  svg.width = data.dimensions.x
  svg.height = data.dimensions.y

socket.on 'players', (players) ->
  console.log 'Got players', players
  for id, player of players
    state.players[id].toDraw.push {x: player.x, y: player.y, trailActive: player.trailActive}
  return


window.initGame = (players) ->
  console.log 'Init game with players', players
  state.players = []
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
  return


window.join = (userName) ->
  socket.emit 'join', {userName: userName}, (id) ->
    console.log 'Joined'
    state.playerId = id

window.controls =
  left: ->
    console.log 'Emitting left'
    socket.emit 'left'

  right: ->
    console.log 'Emitting right'
    socket.emit 'right'

  stop: ->
    console.log 'Emitting stop'
    socket.emit 'stopTurning'



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
  window.field = document.getElementById 'field'
  window.svg = document.getElementById 'svg'

  keyDownHandler controls, document


document.addEventListener 'DOMContentLoaded', () ->
  onReady()
  document.removeEventListener 'DOMContentLoaded', arguments.callee
