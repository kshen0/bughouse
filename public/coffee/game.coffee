window.Game = window.Game or {}

# constants
squareSize = 70;
dark = "#34495e";
light = "#95a5a6";

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

oCanvas.domReady( ()->
  board = createBoard()

  canvas = oCanvas.create {canvas: "#board", background: dark}
  canvas.height = 8 * squareSize; 
  canvas.width = 8 * squareSize; 
  drawBoard(canvas)
  drawPieces(canvas, board)
)

createBoard = () ->
  # letters A - H
  letters = (String.fromCharCode(letter) for letter in [72..65])
  board = ((new window.Square("#{letter}#{num}") for num in [1..8]) for letter in letters)

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
      text = canvas.display.text({
        x: x * squareSize + squareSize / 2;
        y: y * squareSize + squareSize / 2;
        origin: {x: "center", y: "center"},
        font: "bold 12px sans-serif",
        text: if board[x][y].piece? then board[x][y].piece.toString() else board[x][y].name
        fill: "#2980b9";        
      })
      canvas.addChild(text)
      text.dragAndDrop( {
        start: () ->
          startX = this.x
          startY = this.y
          startSquare = board[Math.floor(this.x / squareSize)][Math.floor(this.y / squareSize)]

        end: () ->
          if not startSquare.piece?
            console.log "No piece selected"
            return

          piece = startSquare.piece
          endSquare = board[Math.floor(this.x / squareSize)][Math.floor(this.y / squareSize)]
          that = this
          piece.move endSquare, (isValid) ->
            if not isValid
              that.x = startX
              that.y = startY 


          #console.log sq.name
          #console.log "#{this.abs_x}, #{this.abs_y}"
      })


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


