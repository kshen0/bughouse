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
  green: "#27ae60"
#squareSize = 70
squareSize = 50

# global game vars
boards =
  one: {} 
  two: {} 

playerGameNum = 'unknown'
playerColor = undefined

oCanvas.domReady ()->
  init()

getRoomId = () ->
  url = document.URL.split("/")
  return url[url.length - 1]


init = () ->
  # make two canvases, one for each board
  for boardNum in ["one", "two"]
    canvas = oCanvas.create {canvas: "#board-#{boardNum}", background: COLORS.green}
    canvas.height = 8 * squareSize;
    canvas.width = 12 * squareSize; 
    boards[boardNum].canvas = canvas

  # get game id
  roomId = getRoomId()
  console.log "connected to game #{roomId}"

  # create socket io listeners
  socket.on 'connect', () ->
    sessionId = socket.socket.sessionid
    console.log "sessionId #{sessionId}"
    socket.emit 'newUser', {id: sessionId, name: "player"}
    # connect to the game, get the board state, and render the board
    $.get "/game/player/info/#{sessionId}", handleConnectResponse

  socket.on 'newMove', (moveInfo) ->
    return if moveInfo.player is sessionId
    return if getRoomId() isnt moveInfo.roomId
    start = moveInfo.startSquare
    end = moveInfo.endSquare
    console.log "new incoming move #{moveInfo.piece} #{start}-#{end}"
    game = boards[moveInfo.gameId].board
    startSquare = game.board[start[0]][start[1]]
    endSquare = game.board[end[0]][end[1]]
    game.moveSuccess startSquare.piece.displayObject, startSquare, endSquare

  socket.on 'newDrop', (dropInfo) ->
    return if dropInfo.player is sessionId
    end = dropInfo.endSquare
    console.log "new incoming drop #{dropInfo.piece} on #{end}"
    game = boards[dropInfo.gameId]
    endSquare = game.board[end[0]][end[1]]
    game.dropSuccess game.getUnplacedPieceIndex(dropInfo.piece), endSquare

  socket.on 'transferPiece', (pieceInfo) ->
    console.log "transfer piece"
    console.log pieceInfo
    targetGame = if pieceInfo.gameId is 'one' then 'two' else 'one'
    #if playerColor is pieceInfo.color and playerGameNum is targetGame 
    console.log boards
    boards[targetGame].board.addPieceToGame(pieceInfo)

handleConnectResponse = (resp) ->
  playerColor = resp.color
  playerGameNum = resp.gameNum
  $('#player-label').text "You are #{playerColor} on board #{playerGameNum}" 

  # get board state of the game
  roomId = getRoomId()
  $.get "/game/status/#{roomId}", (resp) ->
    if playerGameNum is 'one'
      boards.one.board = new Board(resp.boards.one, playerColor, boards.one.canvas, "one")
      boards.two.board = new Board(resp.boards.two, 'spectator', boards.two.canvas, "two")
    else if playerGameNum is 'two'
      boards.one.board = new Board(resp.boards.one, 'spectator', boards.one.canvas, "one")
      boards.two.board = new Board(resp.boards.two, playerColor, boards.two.canvas, "two")

class Board
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

  constructor: (boardParams, @playerColor, @canvas, @gameId) ->
    @unplacedPieces = []
    @createBoard(boardParams)
    @drawPieces()
    @drawUnplacedPieces()
    canvas.redraw()
    @calculateThreat()

  createBoard: (boardParams) ->
    # cache the game state from the server
    boardState = boardParams.board
    console.log boardParams

    for unplacedPiece in boardParams.unplacedPieces
      type = unplacedPiece.text
      if type is "pawn"
        console.log "pawn unplaced"
        @unplacedPieces.push new window.Pawn(unplacedPiece)
      else if type is "knight"
        @unplacedPieces.push new window.Knight(unplacedPiece)
      else if type is "bishop"
        @unplacedPieces.push new window.Bishop(unplacedPiece)
      else if type is "rook"
        @unplacedPieces.push new window.Rook(unplacedPiece)
      else if type is "king"
        @unplacedPieces.push new window.King(unplacedPiece)
      else if type is "queen"
        @unplacedPieces.push new window.Queen(unplacedPiece)

    # letters A - H
    letters = (String.fromCharCode(letter) for letter in [72..65])

    # copy over the board and pieces into local Class objects
    @board = ((new window.Square("#{letter}#{num}", num, letter) for num in [1..8]) for letter in letters)
    for y in [0..7]
      for x in [0..7]
        @board[x][y].x = x
        @board[x][y].y = y
        @board[x][y].graphic = @createRectangle(x * squareSize, y * squareSize, if (y + x) % 2 == 0 then COLORS.light else COLORS.dark)
        @board[x][y].threat = boardState[x][y].threat
        @board[x][y].threats = boardState[x][y].threats
        pieceParams = boardState[x][y].piece
        if pieceParams? 
          type = pieceParams.text
          if type is "pawn"
            @board[x][y].piece = new window.Pawn(pieceParams)
          else if type is "knight"
            @board[x][y].piece = new window.Knight(pieceParams)
          else if type is "bishop"
            @board[x][y].piece = new window.Bishop(pieceParams)
          else if type is "rook"
            @board[x][y].piece = new window.Rook(pieceParams)
          else if type is "king"
            @board[x][y].piece = new window.King(pieceParams)
          else if type is "queen"
            @board[x][y].piece = new window.Queen(pieceParams)

  # create canvas squares
  createRectangle: (x, y, color) ->
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

  pickUpPiece: (displayObj) =>
    piece = displayObj.piece
    if not displayObj.piece?
      console.log "could not find a piece for this display object"
      console.log displayObj
      return

    @dragLock = true
    @resetBoardColor()
    @startX = displayObj.x
    @startY = displayObj.y
    if piece.placed
      @startSquare = @board[Math.floor(displayObj.x / squareSize)][Math.floor(displayObj.y / squareSize)]

  dropPiece: (displayObj, playerColor) =>
    #piece = @startSquare.piece
    piece = displayObj.piece

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
    if piece.placed
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
    else if piece.placed is false
      if @endSquare.piece?
        console.log "cannot place a piece on an occupied square"
        revert()
        return
      else
        # TODO: cannot place pawn on either back rank 
        # TODO: cannot place checkmate
        console.log @
        @dropSuccess(@getUnplacedPieceIndex(piece.name), @endSquare, true)
    else
      console.log "unhandled piece state"
      console.log piece
      return

  ###

  getUnplacedPieceIndex: (pieceName) =>
    for i in [0...@unplacedPieces.length]
      console.log "compare: "
      console.log @unplacedPieces[i]
      console.log " with "
      console.log pieceName
      if @unplacedPieces[i].name is pieceName
        return i
  ###

  drawPieces: (canvas, board) =>
    for x in [0..7]
      for y in [0..7]
        if @board[x][y].piece?.displayObject?
          @board[x][y].piece.displayObject.remove()

    for x in [0..7]
      for y in [0..7]
        if @board[x][y].piece?
          img = @canvas.display.image({
            x: x * squareSize + squareSize / 2
            y: y * squareSize + squareSize / 2
            origin: {x: "center", y: "center"}
            height: squareSize
            width: squareSize
            image: @board[x][y].piece.graphic
          })
          @board[x][y].piece.displayObject = img
          @canvas.addChild(img)
          img.piece = @board[x][y].piece

          # define hover behavior
          that = @
          img.bind "mouseenter", () ->
            that.drawThreat @
          img.bind "mouseleave", () ->
            that.undrawThreat @

          # define drag and drop behavior
          img.dragAndDrop 
            start: () ->
              that.pickUpPiece @

            end: () ->
              that.dropPiece @

  drawUnplacedPieces: () =>
    for piece in @unplacedPieces
      img = @canvas.display.image({
        x: squareSize * 8 + squareSize / 2
        y: squareSize / 2 
        origin: {x: "center", y: "center"}
        height: squareSize
        width: squareSize
        image: piece.graphic
      })
      piece.displayObject = img
      @canvas.addChild(img)
      img.piece = piece

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
      sq?.graphic.fill = color or if (sq.y + sq.x) % 2 == 0 then COLORS.light else COLORS.dark

  moveSuccess: (displayObj, startSquare, endSquare, movedBySelf) =>
    if not displayObj?
      console.log "invalid displayObj: #{displayObj}"
      return

    if movedBySelf
      @sendMove(startSquare, endSquare)
    console.log "#{startSquare.piece.text} #{startSquare.name}-#{endSquare.name}"

    # remember the captured piece
    capturedPiece = endSquare.piece
    if capturedPiece?
      capturedPiece.displayObject.remove()
      if movedBySelf
        # lol security
        socket.emit 'capturePiece', 
          roomId: getRoomId()
          gameId: @gameId 
          piece: capturedPiece.name
          color: capturedPiece.color
          text: capturedPiece.text
          placed: false


    # move piece from start square to end square
    startSquare.piece.square = endSquare
    endSquare.piece = startSquare.piece
    startSquare.piece = undefined

    # update the graphic
    displayObj.x = (endSquare.x * squareSize) + squareSize / 2
    displayObj.y = (endSquare.y * squareSize) + squareSize / 2

    # check for pawn promotion
    if endSquare.piece.text is 'pawn'
      if endSquare.piece.color is 'white' and endSquare.y is 7
        console.log 'promote white pawn'
        @drawPromoteDialog 'white', endSquare
      if endSquare.piece.color is 'black' and endSquare.y is 0
        console.log 'promote black pawn'

    @dragLock = false
    @canvas.redraw()
    @toggleTurn()

  drawPromoteDialog: (color, endSquare) =>
    width = 4 * squareSize;
    height = 1.5 * squareSize;
    rectangle = @canvas.display.rectangle( {
      x: squareSize * 4 - width / 2,
      y: squareSize * 4 - height / 2,
      width: width,
      height: height,
      fill: COLORS.green; 
    })

    pieces = ['knight', 'bishop', 'rook', 'queen']
    for pieceName, i in pieces
      sprite = @canvas.display.image({
        x: squareSize * i
        y: squareSize / 4 
        origin: {x: "left", y: "left"}
        height: squareSize
        width: squareSize
        image: "img/#{pieceName}_#{color}.png"
      })


      that = @
      console.log "bind #{pieceName}"
      # TODO: figure out why this always binds the last piece name
      sprite.bind "click", () ->
        that.createPiece @, color, endSquare, rectangle
      rectangle.addChild(sprite)

    @canvas.addChild(rectangle)

  createPiece: (eventInfo, color, endSquare, picker) =>
    filename = eventInfo.img?.src
    if not filename?
      console.log "no imagename found in createPiece"
      return

    if endSquare.piece?
      endSquare.piece.displayObject.remove()

    # sorry not sorry
    if filename.indexOf('knight') > -1 
      endSquare.piece = new window.Knight(color, "knight", true)
    else if filename.indexOf('bishop') > -1 
      endSquare.piece = new window.Bishop(color, "bishop", true)
    else if filename.indexOf('rook') > -1 
      endSquare.piece = new window.Rook(color, "rook", true)
    else if filename.indexOf('queen') > -1 
      endSquare.piece = new window.Queen(color, "queen", true)

    picker.remove()

    @drawPieces()
    @canvas.redraw()

  dropSuccess: (index, endSquare, movedBySelf) =>
    console.log "dropsuccess"

    piece = @unplacedPieces[index]

    if movedBySelf
      @sendDrop(index, endSquare)
    @unplacedPieces.splice index, 1

    displayObj = piece.displayObject

    console.log "dropping #{piece.name} at #{endSquare.name}"

    # add the piece to the board 
    endSquare.piece = piece
    piece.square = endSquare
    piece.placed = true 

    # bind hover listener
    that = @
    displayObj.bind "mouseenter", () ->
      that.drawThreat @
    displayObj.bind "mouseleave", () ->
      that.undrawThreat @

    # update the graphic
    displayObj.x = (endSquare.x * squareSize) + squareSize / 2
    displayObj.y = (endSquare.y * squareSize) + squareSize / 2

    @dragLock = false
    @calculateThreat()
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
    roomId = getRoomId()
    pieceName = startSquare.piece?.text
    if not pieceName?
      console.log "Cannot send move if start square is empty"
      return
    moveInfo =
      roomId: roomId
      player: sessionId
      piece: pieceName
      startSquare: [startSquare.x, startSquare.y]
      endSquare: [endSquare.x, endSquare.y]
      gameId: @gameId
    socket.emit('newMove', moveInfo)

  sendDrop: (index, endSquare) =>
    console.log "send drop"
    console.log "index: #{index}"
    console.log "endsquare: #{endSquare.name}"
    console.log @unplacedPieces
    pieceName = @unplacedPieces[index]?.text
    pieceColor = @unplacedPieces[index]?.color
    if not pieceName?
      console.log "Error finding piece to drop"
      return

    dropInfo =
      player: sessionId
      piece: "#{pieceColor} #{pieceName}"
      endSquare: [endSquare.x, endSquare.y]
      gameId: @gameId
      roomId: getRoomId()

    socket.emit 'newDrop', dropInfo

  addPieceToGame: (pieceInfo) =>
    console.log "adding piece to game:"
    console.log pieceInfo

    pieceName = pieceInfo.piece
    return unless pieceName? 
    colorAndType = pieceName.split " "
    return unless colorAndType.length is 2
    color = colorAndType[0]
    type = colorAndType[1]

    pieceParams =
      color: color
      text: type
      placed: false

    if type is "pawn"
      piece = new window.Pawn(pieceParams)
    if type is "rook"
      piece = new window.Pawn(pieceParams)
    if type is "knight"
      piece = new window.Pawn(pieceParams)
    if type is "bishop"
      piece = new window.Pawn(pieceParams)
    if type is "queen"
      piece = new window.Pawn(pieceParams)

    return unless piece?

    @unplacedPieces.push piece
    @drawUnplacedPieces()

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
