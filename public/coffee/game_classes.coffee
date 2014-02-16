window.Game = window.Game or {}

window.Square = class Square
  constructor: (@name, @piece) ->

window.Piece = class Piece
  constructor: (@color, @text) ->
    console.log "creating piece"

  toString: () ->
    return "#{@color} #{@text}"

window.Pawn = class Pawn extends Piece
  constructor: () ->
    console.log "pawn constructor"
    super
