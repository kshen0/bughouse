window.Game = window.Game or {}

# TODO: game controller class

window.Square = class Square
  constructor: (@name, @piece) ->

  movePiece: (otherSquare) ->
    # return false if no piece on this square
    return false unless @piece?

    if @piece.validMove(otherSquare) and squareIsValid(othersquare)
      console.log 'foo'



window.Piece = class Piece
  constructor: (@color, @text, @square) ->

  move: (square, cb) ->

    console.log @
    if @validMove(square, @color)
      return cb(true)

    return cb(false)

  validMove: (square, thisColor) ->
    # check that piece is moving in correct pattern
    # cannot move on to square containing own piece
    return false if square.piece? and square.piece.color == thisColor
    return true





  toString: () ->
    return "#{@color} #{@text}"

window.Pawn = class Pawn extends Piece
window.Rook = class Rook extends Piece
window.Knight = class Knight extends Piece
window.Bishop = class Bishop extends Piece
window.King = class King extends Piece
window.Queen = class Queen extends Piece
