window.Game = window.Game or {}

# socket io vars
serverBaseUrl = document.domain
socket = io.connect serverBaseUrl
sessionId = ''

# constants
COLORS =
  red: "#e74c3c"
  dark: "#34495e"
  light: "#95a5a6"
squareSize = 70

# global game vars
games =
  one: undefined
  two: undefined

playerGameNum = 'unknown'

oCanvas.domReady ()->
  init()


createGames = (playerInfo) ->
  playerColor = playerInfo.color

  playerGameNum = playerInfo.gameNum

  for gameId in ['one', 'two']
    canvas = oCanvas.create {canvas: "#board-#{gameId}", background: COLORS.dark}
    canvas.height = 8 * squareSize;
    canvas.width = 8 * squareSize; 
    games[gameId] = new ChessGame(canvas, playerColor, gameId)

init = () ->
  # create socket io listeners
  socket.on 'connect', () ->
    sessionId = socket.socket.sessionid
    console.log "sessionId #{sessionId}"
    socket.emit 'newUser', {id: sessionId, name: "player"}
    $.get "/game/player/info/#{sessionId}", createGames 

  socket.on 'newMove', (moveInfo) ->
    return if moveInfo.player is sessionId
    start = moveInfo.startSquare
    end = moveInfo.endSquare
    console.log "new incoming move #{moveInfo.piece} #{start}-#{end}"
    game = games[moveInfo.gameId]
    startSquare = game.board[start[0]][start[1]]
    endSquare = game.board[end[0]][end[1]]
    game.moveSuccess startSquare.piece.displayObject, startSquare, endSquare

class ChessGame
  constructor: (@canvas, @playerColor, @gameId) ->
    @board = @createBoard(@canvas)
    @calculateThreat()
    @drawPieces()

  # allows array indexing by square coordinates
  A: 7
  B: 6
  C: 5
  D: 4
  E: 3
  F: 2
  G: 1
  H: 0

  # vars for piece movement
  startSquare: undefined
  startX: undefined
  startY: undefined
  endSquare: undefined
  dragLock: false
  check: false

  # canvas and dom vars
  canvas: undefined
  boardSquares: []

  # game vars
  board: undefined
  playerColor: undefined
  whitesTurn: true

  createBoard: (canvas) =>
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
    board[@A][0].piece = new window.Rook("white", "rook")
    board[@H][0].piece = new window.Rook("white", "rook")
    board[@A][7].piece = new window.Rook("black", "rook")
    board[@H][7].piece = new window.Rook("black", "rook")

    # Knights 
    board[@B][0].piece = new window.Knight("white", "knight")
    board[@G][0].piece = new window.Knight("white", "knight")
    board[@B][7].piece = new window.Knight("black", "knight")
    board[@G][7].piece = new window.Knight("black", "knight")
    
    # Bishops
    board[@C][0].piece = new window.Bishop("white", "bishop")
    board[@F][0].piece = new window.Bishop("white", "bishop")
    board[@C][7].piece = new window.Bishop("black", "bishop")
    board[@F][7].piece = new window.Bishop("black", "bishop")

    # Kings
    board[@E][0].piece = new window.King("white", "king")
    board[@E][7].piece = new window.King("black", "king")

    # Queens 
    board[@D][0].piece = new window.Queen("white", "queen")
    board[@D][7].piece = new window.Queen("black", "queen")


    # couple each board square with a canvas object
    for x in [0..7]
      for y in [0..7]
        board[x][y].graphic = @createRectangle(x * squareSize, y * squareSize, if (y + x) % 2 == 0 then COLORS.light else COLORS.dark)
    return board

  # create canvas squares
  createRectangle: (x, y, color) =>
    rectangle = @canvas.display.rectangle( {
      x: x,
      y: y,
      width: squareSize; 
      height: squareSize; 
      fill: color; 
    })
    @canvas.addChild(rectangle)
    return rectangle

  drawThreat: (img) =>
    return undefined if @dragLock
    @setSquareColorForImg img, COLORS.red
    @canvas.redraw()

  undrawThreat: (img) =>
    return undefined if @dragLock
    @setSquareColorForImg img
    @canvas.redraw()

  pickUpPiece: (piece) =>
    @dragLock = true
    @resetBoardColor()
    @startX = piece.x
    @startY = piece.y
    @startSquare = @board[Math.floor(piece.x / squareSize)][Math.floor(piece.y / squareSize)]

  dropPiece: (displayObj, playerColor) =>
    piece = @startSquare.piece

    if not piece?
      console.log "No piece selected"
      @dragLock = false
      return

    revert = () =>
      displayObj.x = @startX
      displayObj.y = @startY 
      @dragLock = false


    if playerGameNum isnt @gameId
      console.log "player is playing on board #{playerGameNum} and cannot move pieces on board #{@gameId}" 
      revert()
      return

    if piece.color isnt @playerColor
      console.log "Player is #{@playerColor}. Can't move #{piece.color} piece."
      revert()
      return

    if @playerColor is 'white' and not @whitesTurn or
    @playerColor is 'black' and @whitesTurn
      console.log "#{@playerColor} cannot move out of turn"
      revert()
      return

    @endSquare = @board[Math.floor(displayObj.x / squareSize)][Math.floor(displayObj.y / squareSize)]
    piece.move @startSquare, @endSquare, (isValid) =>
      if not isValid or @isObstructed(@startSquare, @endSquare, @board)
        revert()
      else if @check
        if not @isCheckRemoved(@startSquare, @endSquare)
          colorturn = if @whitesTurn then "white" else "black"
          console.log "#{colorturn} is in check; must move king or block check"
          alert "#{colorturn} is in check; must move king or block check"
          revert()
        else
          @moveSuccess(displayObj, @startSquare, @endSquare, true)
      else
        @moveSuccess(displayObj, @startSquare, @endSquare, true)


  drawPieces: (canvas, board) =>
    for x in [0..7]
      for y in [0..7]
        if @board[x][y].piece?
          img = @canvas.display.image({
            x: x * squareSize + squareSize / 2
            y: y * squareSize + squareSize / 2
            origin: {x: "center", y: "center"}
            image: @board[x][y].piece.graphic
          })
          @board[x][y].piece.displayObject = img
          @canvas.addChild(img)

          # define hover behavior
          that = @
          img.bind "mouseenter", () ->
            that.drawThreat @ ,that.playerColor
          img.bind "mouseleave", () ->
            that.undrawThreat @ ,that.playerColor

          # define drag and drop behavior
          instance = @
          img.dragAndDrop 
            start: () ->
              instance.pickUpPiece @

            end: () ->
              instance.dropPiece @

  resetBoardColor: () =>
    for y in [0..7]
      for x in [0..7]
        if (y + x) % 2 == 0
          @board[x][y].graphic.fill = COLORS.light
        else
          @board[x][y].graphic.fill = COLORS.dark


  # given an oCanvas image object, set the color of its square
  setSquareColorForImg: (img, color) ->
    x = Math.floor(img.x / squareSize)
    y = Math.floor(img.y / squareSize)
    square = @board[x][y]
    piece = square.piece
    return unless piece?
    threatenedSqs = piece.getThreatenedSquares(@board, x, y)
    for sq in threatenedSqs
      sq.graphic.fill = color or if (sq.y + sq.x) % 2 == 0 then COLORS.light else COLORS.dark


  # TODO validate move serverside; check for authenticity client side
  moveSuccess: (displayObj, startSquare, endSquare, movedBySelf) =>
    if not displayObj?
      console.log "invalid displayObj: #{displayObj}"
      return

    # move is already reflected client side, no need to repeat it
    if movedBySelf
      @sendMove(startSquare, endSquare)
    console.log "#{startSquare.piece.text} #{startSquare.name}-#{endSquare.name}"

    # remember the captured piece
    capturedPiece = endSquare.piece
    if capturedPiece?
      capturedPiece.displayObject.remove()
      if movedBySelf
        # lol security
        socket.emit('capturePiece', { gameId: @gameId, piece: capturedPiece.name })

    # move piece from start square to end square
    startSquare.piece.square = endSquare
    endSquare.piece = startSquare.piece
    startSquare.piece = undefined

    # update the graphic
    displayObj.x = (endSquare.x * squareSize) + squareSize / 2
    displayObj.y = (endSquare.y * squareSize) + squareSize / 2

    @dragLock = false
    @canvas.redraw()
    @toggleTurn()


  toggleTurn: () ->
    @whitesTurn = not @whitesTurn
    if @whitesTurn
      $('#turn-label').text "White's turn"
    else
      $('#turn-label').text "Black's turn"

    # recalculate threat for all pieces and squares on the board
    @calculateThreat()
    @resetColors()
    # check for check(mate) for the player whose turn it just became
    @check = @checkForCheck()

  isCheckRemoved: () ->
    if not @check
      console.log "player is not in check to begin with!"
      return false

    # temporarily change board to assess check
    endSqPiece = @endSquare.piece
    @startSquare.piece.square = @endSquare
    @endSquare.piece = @startSquare.piece
    @startSquare.piece = undefined
    @calculateThreat()
    newCheck = @checkForCheck()

    # reset from temporary position
    @endSquare.piece.square = @startSquare
    @startSquare.piece = @endSquare.piece
    @endSquare.piece = endSqPiece
    @calculateThreat()

    return newCheck is false

  checkForCheck: () ->
    # find king
    kingSq = undefined
    colorTurn = if @whitesTurn then "white" else "black"
    for x in [0..7]
      for y in [0..7]
        if @board[x][y].piece?.name is "#{colorTurn} king"
          kingSq = @board[x][y]

    for piece in kingSq.threats
      if piece.color isnt colorTurn
        console.log "#{colorTurn} is in check"
        return true

    return false

  resetColors: () ->
    for x in [0..7]
      for y in [0..7]
        @setSquareColorForImg @board[x][y].graphic

  calculateThreat: () =>
    # reset threat for each square
    for x in [0..7]
      for y in [0..7]
        @board[x][y].threats = []

    # calculate threat for each piece
    for x in [0..7]
      for y in [0..7]
        piece = @board[x][y].piece
        if piece?
          threatenedSquares = piece.getThreatenedSquares(@board, x, y)
          for sq in threatenedSquares
            sq.threats.push piece

  sendMove: (startSquare, endSquare) =>
    pieceName = startSquare.piece?.text
    if not pieceName?
      console.log "Cannot send move if start square is empty"
      return
    moveInfo =
      player: sessionId
      piece: pieceName
      startSquare: [startSquare.x, startSquare.y]
      endSquare: [endSquare.x, endSquare.y]
      gameId: @gameId
    socket.emit('newMove', moveInfo)

  isObstructed: (startSquare, endSquare, board) =>
    # vertical rank check
    if endSquare.x == startSquare.x
      # check in direction from lowest to highest row number
      i = Math.min(startSquare.y, endSquare.y) + 1
      j = Math.max(startSquare.y, endSquare.y) - 1

      # no obstruction if square are adjacent
      return false if j - i < 0 

      for row in [i..j]
        return true if @board[startSquare.x][row].piece?

    # horizontal rank check
    if endSquare.y == startSquare.y
      # check in direction from lowest to highest col number
      i = Math.min(startSquare.x, endSquare.x) + 1
      j = Math.max(startSquare.x, endSquare.x) - 1

      # no obstruction if square are adjacent
      return false if j - i < 0 

      for col in [i..j]
        return true if @board[col][startSquare.y].piece?

    # diagonal obstruction check
    xDist = endSquare.x - startSquare.x
    yDist = endSquare.y - startSquare.y
    slope = xDist / yDist
    if Math.abs(slope) == 1 and Math.abs(xDist) > 1 and Math.abs(yDist) > 1
      #range = [startSquare.x + slope .. endSquare.x - slope]

      # parallel arrays for x, y of squares in between
      xRange = ([startSquare.x .. endSquare.x])[1...-1]
      yRange = ([startSquare.y .. endSquare.y])[1...-1]
      for i in [0...xRange.length]
        return true if @board[xRange[i]][yRange[i]].piece?

    return false

