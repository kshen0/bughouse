window.Game = window.Game or {}

# constants
squareSize = 70;
dark = "#34495e";
light = "#95a5a6";

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
  console.log board[0][0]

  for col in [0..7]
    board[col][1].piece = new window.Pawn("white", "pawn")
    board[col][6].piece = new window.Pawn("black", "pawn")

  return board

drawPieces = (canvas, board) ->
  for x in [0..7]
    for y in [0..7]
      console.log "draw #{x} #{y}"
      console.log board[x][y]
      text = canvas.display.text({
        x: x * squareSize + squareSize / 2;
        y: y * squareSize + squareSize / 2;
        origin: {x: "center", y: "center"},
        font: "bold 12px sans-serif",
        text: if board[x][y].piece? then board[x][y].piece.toString() else board[x][y].name
        fill: "#2980b9";        
      })
      canvas.addChild(text)


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


