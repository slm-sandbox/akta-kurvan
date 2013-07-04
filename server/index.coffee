io = require 'socket.io'

io.listen 8989

io.sockets.on 'connection', (s) ->
  s.emit 'whatsup', { name: 'dawg' }

  s.on 'ciao', (data) ->
    console.log data
