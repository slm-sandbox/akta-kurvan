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


socket = io.connect 'http://localhost:8080'
socket.on 'connect', ->
  console.log "Connected"

socket.on 'newGame', (data) ->
  console.log 'Got new game'
  while svg.lastChild
      svg.removeChild(svg.lastChild);

  svg.width = data.dimensions.x
  svg.height = data.dimensions.y

  initPlayers(data.players)


socket.on 'players', (players) ->
  console.log 'Got players', players
  for id, player of players
    state.players[id].toDraw.push {x: player.x, y: player.y, trailActive: player.trailActive}
  return


window.initPlayers = (players) ->
  console.log 'Init game with players', players
  state.players = []
  for id, player of players
    path = d3svg.append('svg:path')
      .attr("id", id)
      .attr("d", "M #{player.x} #{player.y}")

    if id is state.playerId
      className = 'own'
    else
      className = 'enemy'
    path.attr('class', className)

    state.players[id] = new Player path
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


render = ->
  console.log 'Rendering'
  for id, player of state.players
    path = player.pathElements[player.pathElements.length - 1]
    toDraw = player.toDraw
    player.toDraw = []
    pointsStr = ""
    for point in toDraw
      pointsStr += " L #{point.x} #{point.y}"
    path.attr('d', path.attr('d') + pointsStr)

  requestAnimationFrame ->
    render()

requestAnimationFrame ->
  render()

onReady = ->
  console.log 'Document ready'
  window.field = document.getElementById 'field'
  window.svg = document.getElementById 'svg'
  window.d3svg = d3.select(svg)


  keyDownHandler controls, document


document.addEventListener 'DOMContentLoaded', () ->
  onReady()
  document.removeEventListener 'DOMContentLoaded', arguments.callee
