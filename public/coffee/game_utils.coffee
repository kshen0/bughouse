window.Game = window.Game or {}

window.GameUtils = class GameUtils
  constructor: () ->
  isObstructed: (startSquare, endSquare, board) ->
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

