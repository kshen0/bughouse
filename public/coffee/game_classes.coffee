window.Game = window.Game or {}

window.Square = class Square
  constructor: (@name, @piece) ->

window.Piece = class Piece
  constructor: (@color, @text) ->

  toString: () ->
    return "#{@color} #{@text}"

window.Pawn = class Pawn extends Piece
window.Rook = class Rook extends Piece
window.Knight = class Knight extends Piece
window.Bishop = class Bishop extends Piece
window.King = class King extends Piece
window.Queen = class Queen extends Piece
