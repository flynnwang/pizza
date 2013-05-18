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

cookPaintPizza = (stage, layer, toolbar) ->
  days = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
  [cx, cy, R] = [stage.getWidth() / 2, stage.getHeight() / 2, 235]
  for i in [0..6]
    angle = i * (360/7)
    wedge = new Kinetic.Wedge(
      x: cx
      y: cy
      radius: R
      angleDeg: 360/7
      stroke: "black"
      strokeWidth: 4
      rotationDeg: angle
    )
    _paint = (w) ->
      _ = ->
        w.on "mousedown", ->
          if toolbar.currentTool is "paint"
            w.setFill(toolbar.color)
            layer.draw()
            console.log(toolbar.color)
      _
    _paint(wedge)()
    layer.add(wedge)
  for i in [0..6]
    angle = i * (360/7)
    text = new Kinetic.Text(
      x: cx + (R + 30 - 12) * Math.sin((angle + 7) / 180 * Math.PI)
      y: cy + (R + 30 - 24)* Math.cos((angle + 7) / 180 * Math.PI)
      text: days[6-i]
      fill: "black"
      fontSize: 16
      rotationDeg: 360 - angle - 14
    )
    #text.setZIndex 100
    #console.log days[i]
    #console.log text.getHeight()
    #console.log text.getWidth()
    layer.add(text)
  layer.draw()

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

  trigger: (name) ->
    console.log("#{name} trigged")
    [callback() for callback in @events[name]]

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
      @brushPoint = p
      #@debug('stage-mousemove')
    ).on "mousedown", (evt) =>
      switch @currentTool
        when "text"
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
    ".paint-btn": "paintTool"
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
    console.log(@brushPoint)
    console.log(p)
    line = new Kinetic.Line(
      points: [@brushPoint.x, @brushPoint.y, p.x, p.y]
      stroke: @color
      lineCap: 'round'
      lineJoin: 'round'
      strokeWidth: @strokeWidth
    )
    @stage.get('#brushLayer')[0].add(line).draw()

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
  #pizza = newBrushPizza(stage)
  pizza = new Kinetic.Layer(id: "background")

  toolbar = new Toolbar(
    $container: $('#pizza')
    stage: stage
    background: pizza
    color: "white"
    fontSize: 25
    strokeWidth: 6
  )

  cookPaintPizza(stage, pizza, toolbar)

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
