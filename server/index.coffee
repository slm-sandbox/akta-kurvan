app = require('express')()
server = require('http').createServer app
config = require './../config'

# Asset pipeline attched to express
assets = require 'connect-assets'
locals = {}
assetPipeline = assets
  src: __dirname + '/../client'
  helperContext: locals
locals.js.root = 'js'
locals.css.root = 'css'
locals.img.root = 'img'

# Express configuration
app.configure ->
  app.set 'views', __dirname + '/../client'
  app.set 'view engine', 'jade'
  app.use assetPipeline

# Connect socket to server and game to socket
io = require('socket.io').listen server
io.set "log level", 3
game = require('./game')(io)

# Routes
app.get '/', (req, res) ->
  res.render '../client/index', locals

# Start it up
module.exports = exports = server.listen config.port
