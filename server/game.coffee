uuid = require 'node-uuid'

io = null
players = {}
game = null

radiansPerSecond = 1
pixelsPerSecond = 20
gameLoopInvterval = 100



createGame = ->
  gamePlayers = {}
  for player of players
    gamePlayers[player.id] = createGamePlayer player

  board: [[]]
  players: gamePlayers
  state: 'starting'
  startTime: null
  maxX = 500
  maxY = 500

createPlayer = (username) ->
  id: uuid.v1()
  score: 0
  username: username

createGamePlayer = (player) ->
  x: 50
  y: 50
  angle: 0
  alive: true
  playerId: player.id
  trailActive: false
  username: player.username
  turning: 0

getTime = -> new Date().getTime()

killPlayer = (id) ->
  if game.players[id].alive
    for player of game.players
      if player.alive
        player.score++
    game.players[id].alive = false

collided = (x, y) ->
  if x >= maxX or y >= maxY or x <= 0 or y <= 0
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

gameLoop = (previousTime) ->
  currentTime = getTime()
  dt = currentTime - previousTime
  pixelDiff = pixelsPerSecond * dt
  lastTick = getTime()
  deadPlayers = 0
  for player of game.players
    player.angle += player.turning * radiansPerSecond

    newX = Math.round(player.x + Math.sin(player.angle) * pixelDiff)
    newY = Math.round(player.y + Math.cos(player.angle) * pixelDiff)

    dx = newX - player.x
    dy = newY - player.y
    error = 0
    deltaerr = Math.abs (dy / dx)

    points = []
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

      if collided(x, y)
        killPlayer player.id
        break

    for point in visited
      setVisisted(point.x, point.y)
      setVisisted(point.x - 1, point.y)
      setVisisted(point.x + 1, point.y)
      setVisisted(point.x, point.y - 1)
      setVisisted(point.x, point.y + 1)

    player.x = visited[points.length - 1].x
    player.y = visited[points.length - 1].y

  console.log players
  io.sockets.emit 'players', game.players

  alive = 0
  for player of game.players
    if player.alive
      alive++

  if alive > 1
    setTimeout ->
      gameLoop(currentTime)
    , Math.max(gameLoopInterval - dt, 0)
  else
    startGame()

startGame = ->

  game = createGame()

  io.sockets.emit 'reset',
    maxX: game.maxX
    maxY: game.maxY

  io.sockets.emit 'players', game.players

  do countdown = (i = 5) ->
    io.sockets.emit 'countdown', i

    if i > 0
      setTimeout ->
        countdown i - 1
      , 1000
    else
      gameLoop()

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
      delete players[player.id]
      if game?.players[player.id]
        killPlayer player.id

  startGame()
