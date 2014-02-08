# constants
squareSize = 70;
dark = "#34495e";
light = "#95a5a6";

oCanvas.domReady( ()->
  # letters A - H
  letters = (String.fromCharCode(letter) for letter in [65..72])
  board = (("#{letter}#{num}" for num in [8..1]) for letter in letters)
  console.log board

  canvas = oCanvas.create {canvas: "#board", background: dark}
  canvas.height = 8 * squareSize; 
  canvas.width = 8 * squareSize; 
  drawBoard(canvas)
  drawPieces(canvas, board)
)

drawPieces = (canvas, board) ->
  for x in [0..7]
    for y in [0..7]
      text = canvas.display.text({
        x: x * squareSize + squareSize / 2;
        y: y * squareSize + squareSize / 2;
        origin: {x: "center", y: "center"},
        font: "bold 30px sans-serif",
        text: board[x][y]
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


