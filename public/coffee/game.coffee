window.Game = window.Game or {}

# constants
squareSize = 70
dark = "#34495e"
light = "#95a5a6"

# allows array indexing by square coordinates
A = 7
B = 6
C = 5
D = 4
E = 3
F = 2
G = 1
H = 0

# vars for piece movement
startSquare = undefined
startX = undefined
startY = undefined
endSquare = undefined

# dom vars
canvas = undefined

# game vars
board = undefined
playerColor = undefined
whitesTurn = true

# socket io vars
serverBaseUrl = document.domain
socket = io.connect serverBaseUrl
sessionId = ''

oCanvas.domReady( ()->
  init()
  board = createBoard()

  canvas = oCanvas.create {canvas: "#board", background: dark}
  canvas.height = 8 * squareSize;
  canvas.width = 8 * squareSize; 
  drawBoard(canvas)
  drawPieces(canvas, board)
)

init = () ->
  # create socket io listeners
  socket.on 'connect', () ->
    sessionId = socket.socket.sessionid
    console.log "sessionId #{sessionId}"
    socket.emit 'newUser', {id: sessionId, name: "player"}
    $.get "/game/playercolor/#{sessionId}", (resp) ->
      playerColor = resp
      console.log "player color is #{playerColor}"

  socket.on 'newMove', (moveInfo) ->
    return if moveInfo.player is sessionId
    console.log "moveInfo"
    console.log moveInfo
    start = moveInfo.startSquare
    end = moveInfo.endSquare
    console.log "new incoming move #{moveInfo.piece} #{start}-#{end}"
    startSquare = board[start[0]][start[1]]
    endSquare = board[end[0]][end[1]]
    console.log "startsquare obj"
    console.log startSquare
    moveSuccess startSquare.piece.displayObject, startSquare, endSquare


  ###
  socket.on 'newConnection', (data) ->
    console.log "new connection"
  ###



createBoard = () ->
  # letters A - H
  letters = (String.fromCharCode(letter) for letter in [72..65])
  board = ((new window.Square("#{letter}#{num}", num, letter) for num in [1..8]) for letter in letters)
  for y in [0..7]
    for x in [0..7]
      board[x][y].x = x
      board[x][y].y = y

  ## Create pieces
  # Rows of pawns
  for col in [0..7]
    board[col][1].piece = new window.Pawn("white", "pawn")
    board[col][6].piece = new window.Pawn("black", "pawn")

  # Rooks
  board[A][0].piece = new window.Rook("white", "rook")
  board[H][0].piece = new window.Rook("white", "rook")
  board[A][7].piece = new window.Rook("black", "rook")
  board[H][7].piece = new window.Rook("black", "rook")

  # Knights 
  board[B][0].piece = new window.Knight("white", "knight")
  board[G][0].piece = new window.Knight("white", "knight")
  board[B][7].piece = new window.Knight("black", "knight")
  board[G][7].piece = new window.Knight("black", "knight")

  # Bishops
  board[C][0].piece = new window.Bishop("white", "bishop")
  board[F][0].piece = new window.Bishop("white", "bishop")
  board[C][7].piece = new window.Bishop("black", "bishop")
  board[F][7].piece = new window.Bishop("black", "bishop")

  # Kings
  board[E][0].piece = new window.King("white", "king")
  board[E][7].piece = new window.King("black", "king")

  # Queens 
  board[D][0].piece = new window.Queen("white", "queen")
  board[D][7].piece = new window.Queen("black", "queen")

  return board

drawPieces = (canvas, board) ->
  for x in [0..7]
    for y in [0..7]
      if board[x][y].piece?
        img = canvas.display.image({
          x: x * squareSize + squareSize / 2
          y: y * squareSize + squareSize / 2
          origin: {x: "center", y: "center"}
          image: board[x][y].piece.graphic
        })
        board[x][y].piece.displayObject = img
        canvas.addChild(img)
        img.dragAndDrop( {
          start: () ->
            startX = this.x
            startY = this.y
            startSquare = board[Math.floor(this.x / squareSize)][Math.floor(this.y / squareSize)]

          end: () ->
            piece = startSquare.piece

            if not piece?
              console.log "No piece selected"
              return

            that = this
            revert = () ->
              that.x = startX
              that.y = startY 

            if (playerColor is 'white' and not whitesTurn) or (playerColor is 'black' and whitesTurn)
              console.log "#{playerColor} cannot move when whitesTurn=#{whitesTurn}"
              revert()
              return

            if piece.color isnt playerColor
              console.log "Player is #{playerColor}. Can't move #{piece.color} piece."
              revert()
              return

            endSquare = board[Math.floor(this.x / squareSize)][Math.floor(this.y / squareSize)]
            piece.move startSquare, endSquare, (isValid) ->
              if not isValid or isObstructed(startSquare, endSquare, board)
                revert()
              else
                moveSuccess(that, startSquare, endSquare, true) })

# TODO validate move serverside; check for authenticity client side
moveSuccess = (displayObj, startSquare, endSquare, movedBySelf) ->
  if not displayObj?
    console.log "invalid displayObj: #{displayObj}"
    return

  console.log "displayobj"
  console.log displayObj

  if movedBySelf
    sendMove(startSquare, endSquare)
  console.log "#{startSquare.piece.text} #{startSquare.name}-#{endSquare.name}"
  endSquare.piece.displayObject.remove() if endSquare.piece?
  startSquare.piece.square = endSquare
  endSquare.piece = startSquare.piece
  startSquare.piece = undefined
  displayObj.x = (endSquare.x * squareSize) + squareSize / 2
  displayObj.y = (endSquare.y * squareSize) + squareSize / 2
  ###
  displayObj.x = (displayObj.x - displayObj.x % squareSize) + squareSize / 2
  displayObj.y = (displayObj.y - displayObj.y % squareSize) + squareSize / 2
  ###
  whitesTurn = not whitesTurn
  canvas.redraw()


sendMove = (startSquare, endSquare) ->
  pieceName = startSquare.piece?.text
  if not pieceName?
    console.log "Cannot send move if start square is empty"
    return
  moveInfo =
    player: sessionId
    piece: pieceName
    startSquare: [startSquare.x, startSquare.y]
    endSquare: [endSquare.x, endSquare.y]
  socket.emit('newMove', moveInfo)


drawBoard = (canvas) ->
  createRectangle = (x, y, color) ->
    rectangle = canvas.display.rectangle( {
      x: x,
      y: y,
      width: squareSize; 
      height: squareSize; 
      fill: color; 
    })
    canvas.addChild(rectangle)

  for x in [0..7]
    for y in [0..7]
      createRectangle(x * squareSize, y * squareSize, if (y + x) % 2 == 0 then light else dark)
      #console.log "#{x}, #{y}"

isObstructed = (startSquare, endSquare, board) ->
  # vertical rank check
  if endSquare.x == startSquare.x
    # check in direction from lowest to highest row number
    i = Math.min(startSquare.y, endSquare.y) + 1
    j = Math.max(startSquare.y, endSquare.y) - 1

    # no obstruction if square are adjacent
    return false if j - i < 0 

    for row in [i..j]
      return true if board[startSquare.x][row].piece?

  # horizontal rank check
  if endSquare.y == startSquare.y
    # check in direction from lowest to highest col number
    i = Math.min(startSquare.x, endSquare.x) + 1
    j = Math.max(startSquare.x, endSquare.x) - 1

    # no obstruction if square are adjacent
    return false if j - i < 0 

    console.log "check cols #{i} to #{j}"
    for col in [i..j]
      return true if board[col][startSquare.y].piece?

  # diagonal obstruction check
  xDist = endSquare.x - startSquare.x
  yDist = endSquare.y - startSquare.y
  console.log "xDist #{xDist}"
  console.log "yDist #{yDist}"
  slope = xDist / yDist
  if Math.abs(slope) == 1 and Math.abs(xDist) > 1 and Math.abs(yDist) > 1
    #range = [startSquare.x + slope .. endSquare.x - slope]

    # parallel arrays for x, y of squares in between
    xRange = ([startSquare.x .. endSquare.x])[1...-1]
    yRange = ([startSquare.y .. endSquare.y])[1...-1]
    console.log "xrange"
    console.log xRange
    console.log "yrange"
    console.log yRange
    for i in [0...xRange.length]
      console.log board[xRange[i]][yRange[i]]
      return true if board[xRange[i]][yRange[i]].piece?

  return false

