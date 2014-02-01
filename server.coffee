# node chatroom
# adapted from http://www.williammora.com/2013/03/nodejs-tutorial-building-chatroom-with.html

express = require "express"
app = express()
http = require("http").createServer(app)

# Server config
app.set "ipaddr", "127.0.0.1"
app.set "port", 8080
# Tells server to support JSON, urlencoded, and multipart requests
app.use express.bodyParser()

# Handle GET to /
app.get "/", (request, response) ->
  response.send "Server is up"

# Start server
http.listen app.get("port"), app.get("ipaddr"), () ->
  console.log "Server is running at http://#{app.get('ipaddr')}:#{app.get('port')}"
