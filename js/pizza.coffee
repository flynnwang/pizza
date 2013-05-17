COLORS = ["#f00", "#ff0", "#0f0", "#0ff", "#00f", "#f0f", "#000", "#fff"]
$ ->
  $.each COLORS, ->
    color = this
    a = """<a class="color" data-color="#{color}" style="width: 10px; background: #{color};"></a>"""
    $(".tools").append a

  color = "#0FF"
  $(".color").click (evt) ->
    color = $(this).attr "data-color"

  stage = new Kinetic.Stage(
    container: "painting"
    fill: "white"
    width: 1000
    height: 500
  )
  layer = new Kinetic.Layer()
  circle = new Kinetic.Circle(
    x: stage.getWidth() / 2
    y: stage.getHeight() / 2
    radius: 230
    fill: "white"
    stroke: "black"
    strokeWidth: 4
  )
  center = new Kinetic.Circle(
    x: stage.getWidth() / 2
    y: stage.getHeight() / 2
    radius: 2
    fill: "white"
    stroke: "black"
    strokeWidth: 5
  )

  painting = off
  oldXY = null

  container = stage.getContainer()
  container.addEventListener "mousedown", (evt) ->
    painting = on
    console.log painting

  container.addEventListener "mouseup", (evt) ->
    painting = off
    console.log painting

  stage.on "mousemove", (evt) ->
    cur = stage.getMousePosition()
    if painting and oldXY != null
      line = new Kinetic.Line(
        points: [oldXY.x, oldXY.y, cur.x, cur.y]
        stroke: color
        strokeWidth: 4
      )
      layer.add line
      layer.draw()
    oldXY = cur

  layer.add circle
  layer.add center

  stage.add layer
