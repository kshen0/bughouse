# node chatroom
# adapted from http://www.williammora.com/2013/03/nodejs-tutorial-building-chatroom-with.html

express = require "express"
app = express()
http = require("http").createServer(app)
_ = require "underscore"
io = require("socket.io").listen(http)

participants = []

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

## END routes

io.on "connection", (socket) ->
  socket.on "newUser", (data) ->
    participants.push {id: data.id, name: data.name}
    io.sockets.emit "newConnection", {participants: participants}

io.on "disconnect", () ->
  participants = _.without(participants, _.findWhere(participants, {id: socket.id}))
  io.sockets.emit "userDisconnected", {id: socket.id, sender: "system"}

# Start server
http.listen app.get("port"), app.get("ipaddr"), () ->
  console.log "Server is running at http://#{app.get('ipaddr')}:#{app.get('port')}"
