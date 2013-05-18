# turn off text select
document.onselectstart = () ->
  false

newBrushPizza = (stage) ->
  layer = new Kinetic.Layer(id: "background")
  circle = new Kinetic.Circle(
    x: stage.getWidth() / 2
    y: stage.getHeight() / 2
    radius: 235
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
    strokeWidth: 3
  )
  layer.add(circle)
  layer.add(center)
  layer

class Toolbar
  constructor: (options) ->
    {@$container, @stage, @background, @color, @fontSize, @strokeWidth} = options
    @currentTool = ''
    @brushing = off
    @brushPoint = null
    @textPoint = null
    @setUpColorGroup()
    @events = {}
    @setUpEvents()
    @setUpLayers()

  on: (evt, callback) ->
    @events[evt] = [] if not (evt of @events)
    @events[evt].push(callback)
    return @this

  trigger: (evt) ->
    [callback() for callback in @events[evt]]

  setUpLayers: ->
    @stage.add(@background)
    @stage.add(new Kinetic.Layer(id: "brushLayer"))
    @stage.add(new Kinetic.Layer(id: "paintLayer"))
    @stage.add(new Kinetic.Layer(id: "textLayer"))

  setUpColorGroup: ->
    colors = ["1c39f6", "ff43f7", "61fbb1", "d31710", "00306f", "0086c7", "884aaa", "ff7a29", "fefa51", "00ba6d", "00bfef", "ff1f17", "000", "fff"].reverse()
    $.each colors, ->
      btn = """<button class="color btn" data-color="##{this}" style="background: ##{this};"></button>"""
      $(".toolbar .color-group").append btn

  setUpEvents: ->
    container = @stage.getContainer()
    container.addEventListener "mousedown", =>
      @brushing = on if @currentTool is "brush"
      @debug('container-mousedown')
    container.addEventListener "mouseup", =>
      @brushing = off
      @debug('container-mouseup')
    @stage.on("mousemove", =>
      p = @stage.getMousePosition()
      @brush(p) if @currentTool is "brush" and @brushing and @brushPoint
      @brushPoint = p if @brushing
      @debug('stage-mousemove')
    ).on "mousedown", (evt) =>
      if @currentTool is "text"
        @textPoint = @stage.getMousePosition()
        @trigger("textstart")

    $('.save-btn').button()
    for ctrl, func of @clickEvents
      console.log("#{ctrl} -> #{func}")
      self = @
      _ = (c, f) =>
        $('.toolbar').find(c).click (evt) ->
          self[f](evt)
      _(ctrl, func)

  clickEvents: {
    ".reset-btn": "resetLayer"
    ".text-btn": "textTool"
    ".brush-btn": "brushTool"
    ".size-group button": "changeSize"
    ".color-group button": "changeColor"
    ".save-btn": "saveImage"
  }

  resetLayer: (layerName) ->
    @stage.get(layerName)[0].clear()

  use: (nextTool) ->
    @$container.removeClass(@currentTool) if @currentTool
    @currentTool = nextTool
    @$container.addClass(@currentTool)
    @debug()

  textTool: ->
    @use('text')

  text: (txt) ->
    text = new Kinetic.Text(
      x: @textPoint.x
      y: @textPoint.y
      text: txt
      fill: @color
      fontSize: @fontSize
    )
    @stage.get('#textLayer')[0].add(text).draw()

  brushTool: ->
    @use('brush')

  brush: (p) ->
    console.log(@strokeWidth)
    line = new Kinetic.Line(
      points: [@brushPoint.x, @brushPoint.y, p.x, p.y]
      stroke: @color
      lineCap: 'round'
      lineJoin: 'round'
      strokeWidth: @strokeWidth
    )
    @stage.get('#burshLayer')[0].add(line).draw()

  paintTool: ->
    @use('paint')

  changeSize: (evt) ->
    size= $(evt.target)
    @fontSize = size.attr 'data-font-size'
    @strokeWidth = size.attr 'data-stroke-width'

  changeColor: (evt) ->
    color = $(evt.target)
    @color = color.attr "data-color"

  saveImage: (evt) ->
    save = $('.save-btn')
    save.button('loading')
    @stage.toDataURL(
      callback: (url) =>
        $('.download-btn')
          .attr('href', url)
          .attr('download', "#{window.document.title}.png")
          .show()
        save.button('reset')
      mimeType: "image/png"
    )

  debug: (at=null)->
    console.log "@#{at}: tool: #{@currentTool}, brushing: #{@brushing} with color #{@color}"

$ ->
  drawText = (@i) ->
    txt = @i.val()
    toolbar.text(txt) if txt.trim()

  stage = new Kinetic.Stage(
    container: "pizza"
    fill: "white"
    width: 1000
    height: 500
  )
  pizza = newBrushPizza(stage)

  toolbar = new Toolbar(
    $container: $('#pizza')
    stage: stage
    background: pizza
    color: "black"
    fontSize: 25
    strokeWidth: 6
  )

  dialog = $('#text-dialog').on('shown', ->
    userInput.val '' 
    userInput.focus()
  )
  userInput = $('#user-input')
  dialog.find('.save').click ->
    drawText(userInput)
  userInput.parent().submit (evt) ->
    evt.preventDefault()
    drawText(userInput)
    dialog.modal 'hide'

  toolbar.on("textstart", ->
    dialog.modal('show')
  )
