window.Game = window.Game or {}

# TODO: game controller class

window.Square = class Square
  constructor: (@name, @row, @col, @piece, @x, @y) ->
    @threat = []
  movePiece: (otherSquare) ->
    # return false if no piece on this square
    return false unless @piece?

    if @piece.validMove(otherSquare) and squareIsValid(othersquare)
      console.log 'foo'

window.Piece = class Piece
  constructor: (@color, @text) ->
    @graphic = "img/#{text}_#{color}.png"

  move: (startSquare, endSquare, cb) ->
    if @validMove(startSquare, endSquare)
      console.log "valid move"
      ###
      endSquare.piece.graphic.remove() if endSquare.piece?
      @square = endSquare
      endSquare.piece = startSquare.piece
      startSquare.piece = undefined
      ###
      return cb(true)
    return cb(false)

  validMove: (startSquare, endSquare) ->
    # check that piece is moving in correct pattern
    # cannot move on to square containing own piece
    return false if endSquare.piece? and endSquare.piece.color == @color
    return true

  getThreatenedSquares: (board) ->
    return []

  toString: () ->
    return "#{@color} #{@text}"

window.Pawn = class Pawn extends Piece
  validMove: (startSquare, endSquare) ->
    # return false unless the move passes generic move checking
    return false unless super(startSquare, endSquare)

    dir = 1     # 1 for moving "up" board from 1 to 8, -1 for moving "down" board from 8 to 1
    if @color == "black"
      dir = -1

    # case 1: diagonal capture
    if Math.abs(endSquare.x - startSquare.x) is 1 and
    endSquare.piece? and endSquare.piece.color isnt @color
      return true

    # case 2: forward straight move by 1, no capture
    if dir * (endSquare.row - startSquare.row) is 1 and 
    endSquare.col is startSquare.col and
    not endSquare.piece?
      return true

    # case 3: forward move by 2, no capture, from game start position
    homeRow = 2
    if @color is "black"  
      homeRow = 7
    if startSquare.row is homeRow and
    dir * (endSquare.row - startSquare.row) is 2 and
    endSquare.col is startSquare.col and
    not endSquare.piece?
      return true

    # TODO case 4: en passant

    return false

  getThreatenedSquares: (board, x, y) ->
    sqs = []
    dir = 1     # 1 for moving "up" board from 1 to 8, -1 for moving "down" board from 8 to 1
    if @color == "black"
      dir = -1

    # left diagonal
    if x > 0 and not board[x - 1][y + dir].piece?
      sqs.push board[x - 1][y + dir]
    # right diagonal
    if x < 7 and not board[x - 1][y + dir].piece?
      sqs.push board[x + 1][y + dir]

    return sqs


window.Rook = class Rook extends Piece
  validMove: (startSquare, endSquare) ->
    # return false unless the move passes generic move checking
    return false unless super(startSquare, endSquare)
    return not endSquare.x != startSquare.x and endSquare.y != startSquare.y

  getThreatenedSquares: (board, x, y) ->
    sqs = []

    # check horizontal rank
    for h in [0..7]
      if not window.GameUtils.isObstructed board[x][y], board[h][y], board
        console.log "rook threatens #{h}#{y}"
        sqs.push board[h][y]
    # check vertical rank
    for v in [0..7]
      if not window.GameUtils.isObstructed board[x][y], board[x][v], board
        console.log "rook threatens #{x}#{v}"
        sqs.push board[x][v]

    return sqs

window.Knight = class Knight extends Piece
  validMove: (startSquare, endSquare) ->
    # return false unless the move passes generic move checking
    return false unless super(startSquare, endSquare)

    xDist = Math.abs(endSquare.x - startSquare.x)
    yDist = Math.abs(endSquare.y - startSquare.y)

    return xDist is 1 and yDist is 2 or xDist is 2 and yDist is 1

window.Bishop = class Bishop extends Piece
  validMove: (startSquare, endSquare) ->
    # return false unless the move passes generic move checking
    return false unless super(startSquare, endSquare)

    xDist = endSquare.x - startSquare.x
    yDist = endSquare.y - startSquare.y
    slope = xDist / yDist
    return Math.abs(slope) is 1

window.King = class King extends Piece
  validMove: (startSquare, endSquare) ->
    # TODO mark squares as threatened
    # king cannot move onto threatened squares

    # return false unless the move passes generic move checking
    return false unless super(startSquare, endSquare)

    xDist = Math.abs(endSquare.x - startSquare.x)
    yDist = Math.abs(endSquare.y - startSquare.y)
    return xDist <= 1 and yDist <= 1

    # TODO castling


window.Queen = class Queen extends Piece
  validMove: (startSquare, endSquare) ->
    # return false unless the move passes generic move checking
    return false unless super(startSquare, endSquare)

    xDist = endSquare.x - startSquare.x
    yDist = endSquare.y - startSquare.y
    slope = xDist / yDist

    # diagonal move
    if Math.abs(slope) == 1
      return true

    # horizontal move
    if endSquare.x != startSquare.x and endSquare.y == startSquare.y
      return true

    #vertical move
    if endSquare.x == startSquare.x and endSquare.y != startSquare.y
      return true
