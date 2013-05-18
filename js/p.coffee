window.COLORS = ["1c39f6", "ff43f7", "61fbb1", "d31710", "00306f", "0086c7", "884aaa", "ff7a29", "fefa51", "00ba6d", "00bfef", "ff1f17", "000", "fff"]

document.onselectstart = () ->
  false

$ ->
  $.each window.COLORS, ->
    color = "##{this}"
    a = """<button class="color btn" data-color="#{color}" style="background: #{color};"></button>"""
    $(".tools .color-group").append a

  stage = new Kinetic.Stage(
    container: "pizza"
    fill: "white"
    width: 1000
    height: 500
  )
  tool = ""
  color = "black"
  brushing = off
  oldXY = null
  textXY = null
  fontSize = 25
  paintStrokeWidth = 6

  debug = ->
    console.log "tool: #{tool}, brushing: #{brushing}"


  $(".color").click (evt) ->
    color = $(this).attr "data-color"

  clearCanvas = ->
    stage.clear
    layer = new Kinetic.Layer(
      id: "canvas"
    )
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
    layer.add circle
    layer.add center
    stage.add layer

  # toolbar
  clearCanvas()
  changeTool = (nextTool) ->
    $('#pizza').removeClass(tool) if tool
    tool = nextTool
    $('#pizza').addClass(tool)
  $('#reset-btn').click ->
    clearCanvas()
  $('#text-btn').click ->
    changeTool('text')
  $('#brush-btn').click ->
    changeTool('brush')
  $('.size-group button').click ->
    fontSize = $(this).attr 'data-font-size'
    paintStrokeWidth = $(this).attr 'data-stroke-width'
    console.log(fontSize)
    console.log(paintStrokeWidth)

  container = stage.getContainer()
  container.addEventListener "mousedown", (evt) ->
    if tool == "brush"
      brushing = on
    debug()

  container.addEventListener "mouseup", (evt) ->
    brushing = off
    debug()

  stage.on "mousemove", (evt) ->
    cur = stage.getMousePosition()
    if tool == "brush"
      #debug()
      if brushing and oldXY != null
        console.log(paintStrokeWidth)
        line = new Kinetic.Line(
          points: [oldXY.x, oldXY.y, cur.x, cur.y]
          stroke: color
          lineCap: 'round'
          lineJoin: 'round'
          strokeWidth: paintStrokeWidth
        )
        stage.get('#canvas')[0].add(line).draw()
    oldXY = cur

  # text painting
  userInput = $('#user-input')
  dialog = $('#text-dialog').on('shown', () ->
    userInput.focus()
  )
  paintText = () ->
    text = new Kinetic.Text(
      x: textXY.x
      y: textXY.y
      text: userInput.val()
      fill: color
      fontSize: fontSize
    )
    stage.get('#canvas')[0].add(text).draw()
    userInput.val ''
    dialog.modal 'hide'

  dialog.find('.save').click () ->
    paintText()
  userInput.parent().submit (evt) ->
    evt.preventDefault()
    paintText()

  stage.on "mousedown", (evt) ->
    debug()
    if tool == "text"
      brushing = off
      textXY = stage.getMousePosition()
      dialog.modal()

  # png download
  $('#save-btn').click (evt) ->
    $(this).button('loading')
    stage.toDataURL(
      callback: (url) =>
        $('#download-btn').attr('href', url)
        $('#download-btn').attr('download', "#{window.document.title}.png")
        $(this).button('reset')
        $('#download-btn').show()
        console.log url
      mimeType: "image/png"
    )
  $('#download-btn').hide().click ->
    $('#save-btn').show()

  $('#save-btn').button()
