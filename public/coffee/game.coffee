# constants
squareSize = 70;
dark = "#34495e";
light = "#95a5a6";

oCanvas.domReady( ()->

  canvas = oCanvas.create {canvas: "#board", background: dark}
  canvas.height = 8 * squareSize; 
  canvas.width = 8 * squareSize; 
  createBoard(canvas)
  ###
  board = ((x for x in [1..8]) for x in [1..8])
  console.log board
  ###
)

createBoard = (canvas) ->
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


