_.templateSettings =
  interpolate: /\{\{(.+?)\}\}/g

@CrosshairSelector = Backbone.View.extend
	className: "crosshair-selector"
	height: 200
	width: 200
	dotSize: 10
	notchSpacing: 10
	notchWidth: 10

	_mouseState: false
	
	template: _.template("""
		<canvas class='bg' height="{{height}}" width="{{width}}"></canvas>
		<canvas class='fg' height="{{height}}" width="{{width}}"></canvas>
	""")

	generateBackground: ->
		node = @$('.bg')[0]
		ctx = node.getContext('2d')
		height = node.height
		width = node.width
		origin = [node.width/2, node.height/2]

		ctx.beginPath()
		
		# vertical line
		ctx.moveTo(width / 2, 0)
		ctx.lineTo(width / 2, height)
		
		# horizontal line
		ctx.moveTo(0, height / 2)
		ctx.lineTo(width, height / 2)
	
		# notches
		i = j = origin[0]
		start = origin[1] - @notchWidth / 2
		end = origin[1] + @notchWidth / 2
		while i <= width
			i += @notchSpacing
			j -= @notchSpacing
			ctx.moveTo(i, start)
			ctx.lineTo(i, end)
			ctx.moveTo(j, start)
			ctx.lineTo(j, end)
	
		i = j = origin[1]
		start = origin[0] - @notchWidth / 2
		end = origin[0] + @notchWidth / 2
		while i <= height
			i += @notchSpacing
			j -= @notchSpacing
			ctx.moveTo(start, i)
			ctx.lineTo(end, i)
			ctx.moveTo(start, j)
			ctx.lineTo(end, j)
	
		ctx.stroke()
		return
	
	setCrosshair: (e) ->
		e.preventDefault()
		
		node = @$(".fg")[0]
		ctx = node.getContext('2d')
		
		mousePos = h337.util.mousePosition(e)
		return unless mousePos?
		x = Math.max(0, Math.min(mousePos[0], node.width))
		y = Math.max(0, Math.min(mousePos[1], node.height))

		ctx.clearRect(0, 0, node.width, node.height)
		ctx.beginPath()
		ctx.moveTo(x-@dotSize, y)
		ctx.lineTo(x+@dotSize, y)
		ctx.moveTo(x, y-@dotSize)
		ctx.lineTo(x, y+@dotSize)
		ctx.stroke()
		
		@_heatmap.store.addDataPoint(x, y)
		return @coords = {x: x, y: y}

	setCoordText: ->
		node = @$(".bg")[0]
		textCtx = node.getContext('2d')
		textSize = node.height / 20
		availableWidth = node.width/2 - @notchWidth/2

		textCtx.clearRect(0, 0, availableWidth, textSize*2)
		textCtx.font = "#{textSize}px monospace"
		textCtx.textBaseline = "top"
		textCtx.fillText("(#{@coords.x}, #{@coords.y})", 3, 3)
	
	showHeatmap: ->
		$(@_heatmap.get('canvas')).show()
	
	hideHeatmap: ->
		$(@_heatmap.get('canvas')).hide()

	events:
		"mousedown": (e) ->
			@_mouseState = true
			@setCrosshair(e)
			@setCoordText()
	
	setGlobalEvents: ->
		self = this

		$(window).on "mouseup", (e) ->
			((e) ->
				return unless @_mouseState
				@_mouseState = false
				$(".canvas-filter").remove()
				$("body").css('cursor', '')
			).call(self, e)

		$(window).on "mousemove", (e) ->
			((e) ->
				return unless @_mouseState
				$('body').css('cursor', 'move')
				@setCrosshair(e)
				@setCoordText()
			).call(self, e)

	initialize: (obj={}) ->
		@height = parseInt(obj.height, 10) if obj.height?
		@width = parseInt(obj.width, 10) if obj.width?
		@dotSize = parseInt(obj.dotSize, 10) if obj.dotSize?
		@notchSpacing = parseInt(obj.notchSpacing, 10) if obj.notchSpacing?
		return

	render: ->
		@$el.empty().append(
			@template(height: @height, width: @width)
		).css
			height: @height
			width: @width
		
		@$el.children().css
			height: @height
			width: @width

		@generateBackground()
		@setGlobalEvents()
		
		@_heatmap = h337.create
			element: @el
			radius: 15
			visible: false
		@_heatmap.get('canvas').style.zIndex = 0
		return @
