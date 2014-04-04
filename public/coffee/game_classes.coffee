window.Game = window.Game or {}

# TODO: game controller class

window.Square = class Square
  constructor: (@name, @row, @col, @piece, @x, @y) ->
    @threat = []

window.Piece = class Piece
  constructor: (@color, @text, @placed) ->
    @graphic = "img/#{text}_#{color}.png"
    @name = "#{@color} #{@text}"

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
    #if x > 0 and not board[x - 1][y + dir].piece?
    if x > 0
      sqs.push board[x - 1][y + dir]
    # right diagonal
    #if x < 7 and not board[x + 1][y + dir].piece?
    if x < 7
      sqs.push board[x + 1][y + dir]

    return sqs

window.Rook = class Rook extends Piece
  validMove: (startSquare, endSquare) ->
    # return false unless the move passes generic move checking
    return false unless super(startSquare, endSquare)
    return not (endSquare.x != startSquare.x and endSquare.y != startSquare.y)

  getThreatenedSquares: (board, x, y) ->
    return getStraightThreat(board, x, y)



window.Knight = class Knight extends Piece
  validMove: (startSquare, endSquare) ->
    # return false unless the move passes generic move checking
    return false unless super(startSquare, endSquare)

    xDist = Math.abs(endSquare.x - startSquare.x)
    yDist = Math.abs(endSquare.y - startSquare.y)

    return xDist is 1 and yDist is 2 or xDist is 2 and yDist is 1

  getThreatenedSquares: (board, x, y) ->
    coords = [
      {x: x-1, y: y-2}
      {x: x+1, y: y-2}
      {x: x+2, y: y-1}
      {x: x+2, y: y+1}
      {x: x+1, y: y+2}
      {x: x-1, y: y+2}
      {x: x-2, y: y+1}
      {x: x-2, y: y-1}
    ]
    sqs = []
    #sqs = (board[coord.x][coord.y] if coord.x >= 0 and coord.y >= 0 for coord in coords)
    for coord in coords
      if coord.x >=0 and coord.y >= 0 and
      coord.x < 8 and coord.y < 8
      #not board[coord.x][coord.y].piece?
        sqs.push board[coord.x][coord.y]
    return sqs

window.Bishop = class Bishop extends Piece
  validMove: (startSquare, endSquare) ->
    # return false unless the move passes generic move checking
    return false unless super(startSquare, endSquare)

    xDist = endSquare.x - startSquare.x
    yDist = endSquare.y - startSquare.y
    slope = xDist / yDist
    return Math.abs(slope) is 1

  getThreatenedSquares: (board, x, y) ->
    return getDiagonalThreat(board, x, y)

window.King = class King extends Piece
  validMove: (startSquare, endSquare) ->
    # return false unless the move passes generic move checking
    return false unless super(startSquare, endSquare)

    # can't move on to threatened square
    threats = endSquare.threats or []
    for piece in threats
      if piece.color isnt @color
        console.log "can't move king on to threatened square"
        return false

    xDist = Math.abs(endSquare.x - startSquare.x)
    yDist = Math.abs(endSquare.y - startSquare.y)
    return xDist <= 1 and yDist <= 1

    # TODO castling

  getThreatenedSquares: (board, x, y) ->
    coords = [
      {x: x-1, y: y-1}
      {x: x, y: y-1}
      {x: x+1, y: y-1}
      {x: x+1, y: y}
      {x: x+1, y: y+1}
      {x: x, y: y+1}
      {x: x-1, y: y+1}
      {x: x-1, y: y}
    ]
    sqs = []
    #sqs = (board[coord.x][coord.y] if coord.x >= 0 and coord.y >= 0 for coord in coords)
    for coord in coords
      if coord.x >=0 and coord.y >= 0 and
      coord.x < 8 and coord.y < 8
        sqs.push board[coord.x][coord.y]
    return sqs

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

  getThreatenedSquares: (board, x, y) ->
    return getStraightThreat(board, x, y).concat getDiagonalThreat(board, x, y)

##############################
## Threat computation helper functions
##############################

# horizontal and vertical threat
getStraightThreat = (board, x, y) ->
  threatenedSqs = []
  # check left
  for col in [x-1 .. 0]
    break if col is -1
    if board[col][y].piece?
      threatenedSqs.push board[col][y] 
      break
    threatenedSqs.push board[col][y]
  # check right
  for col in [x+1 .. 7]
    break if col is 8
    if board[col][y].piece?
      threatenedSqs.push board[col][y] 
      break
    threatenedSqs.push board[col][y]

  # up and down
  #for row in [Math.max(y-1, 0) .. 0]
  for row in [y-1 .. 0]
    break if row is -1
    if board[x][row].piece?
      threatenedSqs.push board[x][row]
      break
    threatenedSqs.push board[x][row]

  for row in [y+1 .. 7]
    break if row is 8
    if board[x][row].piece?
      threatenedSqs.push board[x][row]
      break
    threatenedSqs.push board[x][row]

  return threatenedSqs

getDiagonalThreat = (board, x, y) ->
  threatenedSqs = []

  # upper left check
  row = y - 1
  col = x - 1
  while row >= 0 and col >= 0
    if board[col][row].piece?
      threatenedSqs.push board[col][row]
      break

    threatenedSqs.push board[col][row]
    row--
    col-- 

  # upper right check
  row = y - 1
  col = x + 1
  while row >= 0 and col < 8 
    if board[col][row].piece?
      threatenedSqs.push board[col][row]
      break
    threatenedSqs.push board[col][row]
    row--
    col++ 

  # lower right check
  row = y + 1
  col = x + 1
  while row < 8 and col < 8 
    if board[col][row].piece?
      threatenedSqs.push board[col][row]
      break
    threatenedSqs.push board[col][row]
    row++
    col++ 

  # lower left check
  row = y + 1
  col = x - 1
  while row < 8 and col >= 0
    if board[col][row].piece?
      threatenedSqs.push board[col][row]
      break
    threatenedSqs.push board[col][row]
    row++
    col--

  return threatenedSqs
