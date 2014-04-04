# node chatroom
# adapted from http://www.williammora.com/2013/03/nodejs-tutorial-building-chatroom-with.html

express = require "express"
app = express()
http = require("http").createServer(app)
_ = require "underscore"
io = require("socket.io").listen(http)

participants = {} 

# Server config
app.set "ipaddr", "127.0.0.1"
app.set "port", 8080
# Specify views
app.set "views", "#{__dirname}/views"
app.set "view engine", "jade"
app.use(express.static("public", "#{__dirname}/public"))
# Tells server to support JSON, urlencoded, and multipart requests
app.use express.bodyParser()



# routes 
app.get "/", (request, response) ->
  response.render "index"

app.post "/message", (request, response) ->
  message = request.body.message
  return response.json(400, {error: "Invalid message"}) if _.isUndefined(message) || _.isEmpty(message.trim())

  name = request.body.name
  io.sockets.emit "incomingMessage", {message: message, name: name}
  response.json 200, {message: "Message received"}

app.get "/game", (request, response) ->
  response.render "game"

app.get "/game/player/info/:sessionId", (request, response) ->
  sessionId = request.params.sessionId
  console.log "request for player info for player #{request.params.sessionId}"
  #response.send {color: participants[sessionId].color}
  response.send participants[sessionId]

## END routes

io.on "connection", (socket) ->
  socket.on "newUser", (data) ->
    console.log data
    if _.size(participants) % 2 is 0
      playerColor = "white"
    else
      playerColor = "black"

    if _.size(participants) / 2 < 1
      # first or second connection
      gameNum = 'one'
    else if _.size(participants) / 2 < 2 
      # third or fourth connection
      gameNum = 'two'

    participants[data.id] = name: data.name, color: playerColor, gameNum: gameNum
    #io.sockets.emit "newConnection", {participants: participants}

  socket.on "newMove", (moveInfo) ->
    # TODO validate move
    player = participants[moveInfo.player]
    if not player?
      console.log "invalid player id: #{moveInfo.player}"
      return

    if player.gameNum isnt moveInfo.gameId
      console.log "player #{moveInfo.player} cannot make moves on board #{moveInfo.gameId}" 
      return

    io.sockets.emit "newMove", moveInfo

  socket.on "newDrop", (moveInfo) ->
    # TODO validate move
    player = participants[moveInfo.player]
    if not player?
      console.log "invalid player id: #{moveInfo.player}"
      return

    if player.gameNum isnt moveInfo.gameId
      console.log "player #{moveInfo.player} cannot make moves on board #{moveInfo.gameId}" 
      return

    console.log "new drop"
    console.log moveInfo

    io.sockets.emit "newDrop", moveInfo

  socket.on "capturePiece", (capture) ->
    gameId = capture.gameId
    piece = capture.piece
    console.log "piece captured:"
    console.log capture
    io.sockets.emit "transferPiece", { gameId: gameId, piece: piece, color: capture.color }

###
io.on "disconnect", () ->
  participants = _.without(participants, _.findWhere(participants, {id: socket.id}))
  io.sockets.emit "userDisconnected", {id: socket.id, sender: "system"}
###

# Start server
http.listen app.get("port"), app.get("ipaddr"), () ->
  console.log "Server is running at http://#{app.get('ipaddr')}:#{app.get('port')}"
