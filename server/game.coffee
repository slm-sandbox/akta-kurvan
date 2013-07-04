uuid = require 'node-uuid'

io = null
players = {}
game = null

radiansPerSecond = 1
pixelsPerSecond = 20
gameLoopInterval = 100
immortalTime = 3000

createGame = ->
  gamePlayers = {}
  for _, player of players
    gamePlayers[player.id] = createGamePlayer player

  board: [[]]
  players: gamePlayers
  state: 'starting'
  startTime: getTime()
  dimensions:
    x: 500
    y: 500

createPlayer = (username) ->
  id: uuid.v1()
  score: 0
  username: username

createGamePlayer = (player) ->
  x: 50
  y: 50
  angle: 0
  alive: true
  id: player.id
  trailActive: false
  username: player.username
  turning: 0

getTime = -> new Date().getTime()

killPlayer = (id) ->
  if game?.players[id]?.alive
    for _, player of game.players
      if player.alive
        player.score++
    game.players[id].alive = false

collided = (x, y) ->
  if x >= game.dimensions.x or y >= game.dimensions.y or x <= 0 or y <= 0
    return true
  else
    game.board[y] = game.board[y] || []
    return !!game.board[y][x]

setVisited = (x, y) ->
  game.board[y] = game.board[y] || []
  x = Math.max 0, x
  y = Math.min 0, y
  game.board[y] = game.board[y] || []
  game.board[y][x] = true

gameOver = ->
  io.sockets.emit 'gameOver'
  startGame()

movePlayer = (player, numPixels) ->
  return if numPixels is 0
  console.log numPixels

  player.angle += player.turning * radiansPerSecond

  newX = Math.round(player.x + Math.sin(player.angle) * numPixels)
  newY = Math.round(player.y + Math.cos(player.angle) * numPixels)

  dx = newX - player.x
  dy = newY - player.y
  points = []
  if dx is 0
    for y in [player.y ... newY]
      points.push
        x: player.x
        y: y
  else

    error = 0
    deltaerr = Math.abs (dy / dx)

    y = player.y
    for x in [player.x ... newX]
      points.push
        x: x
        y: y
      error += deltaerr
      if error >= 0.5
        y += 1
        error -= 1.0

  visited = []

  for point in points
    visited.push point

    if getTime() - game.startTime > immortalTime and collided(point.x, point.y)
      killPlayer player.id
      break

  for point in visited
    setVisisted(point.x, point.y)
    setVisisted(point.x - 1, point.y)
    setVisisted(point.x + 1, point.y)
    setVisisted(point.x, point.y - 1)
    setVisisted(point.x, point.y + 1)


  player.x = visited[visited.length - 1].x
  player.y = visited[visited.length - 1].y

gameLoop = (previousStepStartTime) ->
  thisStepStartTime = getTime()
  dt = thisStepStartTime - previousStepStartTime
  numPixels = pixelsPerSecond * dt

  for _, player of game.players
    movePlayer player, numPixels

  io.sockets.emit 'players', game.players

  alive = 0
  for _, player of game.players
    if player.alive
      alive++

  if alive > 1
    setTimeout ->
      gameLoop(thisStepStartTime)
    , Math.max(gameLoopInterval - dt, 0)
  else
    gameOver()

startGame = ->
  game = createGame()

  io.sockets.emit 'newGame',
    dimensions: game.dimensions
    players: game.players

  do countdown = (i = 5) ->
    io.sockets.emit 'countdown', i

    if i > 0
      setTimeout ->
        countdown i - 1
      , 1000
    else
      gameLoop(getTime())

module.exports = exports = (_io) ->
  io = _io

  io.on 'connection', (socket) ->
    player = null

    socket.on 'join', (data, cb) ->
      player = createPlayer data.username
      players[player.id] = player

      socket.on 'left', ->
        game.players[player.id].turning = -1

      socket.on 'right', ->
        game.players[player.id].turning = 1

      socket.on 'stopTurning', ->
        game.players[player.id].turning = 0

      cb null, player.id

      socket.on 'disconnect', ->
        killPlayer player.id
        delete players[player.id]

  startGame()
