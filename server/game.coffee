require 'node-uuid'

io = null
players = {}
game = null

radiansPerSecond = 0
pixelsPerSecond = 0
gameLoopLimit = 100


createGame = ->
  gamePlayers = players.map (player) ->
    createGamePlayer player

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
  x: 500
  y: 500
  angle: 0
  alive: true
  playerId: player.id
  trailActive: false
  username: player.username
  turning: 0


io.on 'connection', (socket) ->
  player = null

  socket.on 'join', (data, cb) ->
    player = createPlayer data.username
    players[player.id] = player

    socket.on 'left', ->
      game.players[players.id].turning = -1

    socket.on 'right', ->
      game.players[players.id].turning = 1

    socket.on 'stopTurning', ->
      game.players[players.id].turning = 0

    cb null, player.id

  socket.on 'disconnect', ->
    delete players[player.id]

do startGame = ->
  getTime = -> new Date().getTime() / 1000

  game = createGame()
  lastTick = getTime()

  io.broadcast 'reset',
    maxX: game.maxX
    maxY: game.maxY

  do gameLoop = ->
    dt = getTime() - lastTick
    pixelDiff = pixelsPerSecond * dt
    lastTick = getTime()
    deadPlayers = 0
    game.players.forEach (player) ->
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

      collided = (x, y) ->
        if x >= maxX or y >= maxY or x =< 0 or y =< 0
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

      visited = []
      for point in points
        visited.push point

        if collided(x, y)
          game.players.forEach (player) ->
            if player.alive
              player.score++
          player.alive = false
          break

      for point in visited
        setVisisted(point.x, point.y)
        setVisisted(point.x - 1, point.y)
        setVisisted(point.x + 1, point.y)
        setVisisted(point.x, point.y - 1)
        setVisisted(point.x, point.y + 1)

      player.x = visited[points.length - 1].x
      player.y = visited[points.length - 1].y

    io.broadcast 'players', players

    alive = 0
    game.players.forEach (player) ->
      if player.alive
        alive++

    if alive > 1
      setTimeout gameLoop, Math.max(gameLoopLimit-dt, 0)
    else
      startGame()



module.exports = exports = (_io) ->
  io = _io
