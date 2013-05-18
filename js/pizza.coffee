$ ->
  $.each window.C.COLORS, ->
    color = "##{this}"
    a = """<button class="color btn" data-color="#{color}" style="background: #{color};"></button>"""
    $(".tools .color-group").append a

  stage = new Kinetic.Stage(
    container: "painting"
    fill: "white"
    width: 1000
    height: 500
  )
  tool = ""
  color = "black"
  painting = off
  oldXY = null
  textXY = null
  fontSize = 25
  paintStrokeWidth = 6

  debug = ->
    console.log "tool: #{tool}, painting: #{painting}"


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
    $('#painting').removeClass(tool) if tool
    tool = nextTool
    $('#painting').addClass(tool)
  $('#reset-btn').click ->
    clearCanvas()
  $('#text-btn').click ->
    changeTool('text')
  $('#paint-btn').click ->
    changeTool('paint')
  $('.size-group button').click ->
    fontSize = $(this).attr 'data-font-size'
    paintStrokeWidth = $(this).attr 'data-stroke-width'
    console.log(fontSize)
    console.log(paintStrokeWidth)

  container = stage.getContainer()
  container.addEventListener "mousedown", (evt) ->
    if tool == "paint"
      painting = on
    debug()

  container.addEventListener "mouseup", (evt) ->
    painting = off
    debug()

  stage.on "mousemove", (evt) ->
    cur = stage.getMousePosition()
    if tool == "paint"
      #debug()
      if painting and oldXY != null
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
      painting = off
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
