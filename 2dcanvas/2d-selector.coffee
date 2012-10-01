_.templateSettings =
  interpolate: /\{\{(.+?)\}\}/g

@CrosshairSelector = Backbone.View.extend
	className: "crosshair-selector"
	height: 200
	width: 200
	dotSize: 10
	notchSpacing: 10
	notchWidth: 10

	_bgState: true
	_mouseState: false
	_lastColourPoint: "#000000"
	
	_ensureBetween: (num, min, max) ->
		return Math.max(min, Math.min(num, max))

	_mousePosition: (node, e) ->
		# Firefox gives floats and not ints...
		x = parseInt(e.pageX - $(node).offset().left, 10)
		y = parseInt(e.pageY - $(node).offset().top, 10)

		x = Math.max(0, Math.min(x, node.width))
		y = Math.max(0, Math.min(y, node.height))
		
		return [x, y]

	_getImageData: (ctx, node) ->
		x = Math.max(0, Math.min(@coords.x, node.width-1))
		y = Math.max(0, Math.min(@coords.y, node.height-1))
		[r, g, b] = ctx.getImageData(x, y, 1, 1).data
		
		return "rgb(#{r},#{g},#{b})"

	_generateCross: ->
		node = @$('.ch')[0]
		ctx = node.getContext('2d')
		height = node.height
		width = node.width
		origin = [node.width/2, node.height/2]

		ctx.save()
		ctx.clearRect(0, 0, node.width, node.height)
		ctx.lineWidth = 2
		ctx.strokeStyle = @_lastColourPoint if @_bgState
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
		ctx.restore()
		return

	_generateBackground: ->
		bg = @$('.bg')[0]
		ctx = bg.getContext('2d')
		height = bg.height
		width = bg.width
		origin = [bg.width/2, bg.height/2]

		# green to red horizontal gradient
		horizontalGradient = ctx.createLinearGradient(0, 0, width, 0)
		horizontalGradient.addColorStop(0, "#00ff00")
		horizontalGradient.addColorStop(1, "#ff0000")
		
		# transparent to white vertical gradient
		verticalGradient = ctx.createLinearGradient(0, 0, 0, height)
		verticalGradient.addColorStop(0, "rgba(0,0,0,0)")
		verticalGradient.addColorStop(1, "rgba(255,255,255,1)")
		
		ctx.save()
		ctx.fillStyle = horizontalGradient
		ctx.fillRect(0, 0, width, height)
		ctx.fillStyle = verticalGradient
		ctx.fillRect(0, 0, width, height)
		ctx.restore()
		return
	
	_setCrosshair: () ->
		fg = @$(".fg")[0]
		bg = @$(".bg")[0]
		ctx = fg.getContext('2d')
		bgCtx = bg.getContext('2d')

		@_lastColourPoint = @_getImageData(bgCtx, fg)
		@_generateCross()
		ctx.clearRect(0, 0, fg.width, fg.height)
		ctx.beginPath()
		x = @coords.x
		y = @coords.y
		ctx.moveTo(x-@dotSize, y)
		ctx.lineTo(x+@dotSize, y)
		ctx.moveTo(x, y-@dotSize)
		ctx.lineTo(x, y+@dotSize)
		ctx.stroke()
		
		@_heatmap.store.addDataPoint(x, y)
		@_setCoordText()
		return @coords

	_setCoords: (x, y) ->
		return @coords = {x: x, y: y}

	_setCoordText: ->
		return unless @coords?
		node = @$(".ch")[0]
		textCtx = node.getContext('2d')
		textSize = node.height / 20
		availableWidth = node.width/2 - @notchWidth/2
		
		howMuchICare = node.width/2 - @coords.x
		howMuchIAgree = node.height - @coords.y

		textCtx.clearRect(0, 0, availableWidth, textSize*2)
		textCtx.font = "#{textSize}px monospace"
		textCtx.textBaseline = "top"
		textCtx.fillText("(#{howMuchICare}, #{howMuchIAgree})", 3, 3)
	
	_setGlobalEvents: ->
		self = this

		$(window).on "mouseup", (e) ->
			((e) ->
				return unless @_mouseState
				@_mouseState = false
				$(".canvas-filter").remove()
			).call(self, e)

		$(window).on "mousemove", (e) ->
			((e) ->
				return unless @_mouseState
				e.preventDefault()
				[x, y] = @_mousePosition(@$(".fg")[0], e)
				@_setCoords(x, y)
				@_setCrosshair()
			).call(self, e)

		return

	events:
		"mousedown": (e) ->
			@_mouseState = true
			$('body').append($('<div class="canvas-filter"></div>'))
			@$(".fg").addClass('moving')
			e.preventDefault()
			[x, y] = @_mousePosition(@$(".fg")[0], e)
			@_setCoords(x, y)
			@_setCrosshair()
	
	template: _.template("""
		<canvas class='bg' height="{{height}}" width="{{width}}"></canvas>
		<canvas class='ch' height="{{height}}" width="{{width}}"></canvas>
		<canvas class='fg' height="{{height}}" width="{{width}}"></canvas>
	""")

	initialize: (obj={}) ->
		@height = parseInt(obj.height, 10) if obj.height?
		@width = parseInt(obj.width, 10) if obj.width?
		@dotSize = parseInt(obj.dotSize, 10) if obj.dotSize?
		@notchSpacing = parseInt(obj.notchSpacing, 10) if obj.notchSpacing?
		return

	showBackground: ->
		@_bgState = true
		@$(".bg").show()
		@_generateCross()

	hideBackground: ->
		@_bgState = false
		@$(".bg").hide()
		@_generateCross()
	
	showHeatmap: ->
		$(@_heatmap.get('canvas')).show()
	
	hideHeatmap: ->
		$(@_heatmap.get('canvas')).hide()

	set: (agree, care) ->
		node = @$(".ch")[0]
		x_diff = node.width / 100
		y_diff = node.height / 100
		@coords =
			x: node.width/2 - x_diff * @_ensureBetween(agree, -50, 50)
			y: node.height - y_diff * @_ensureBetween(care, 0, 100)

		@_setCrosshair()
	
	render: ->
		@$el.empty().append(
			@template(height: @height, width: @width)
		).css
			height: @height
			width: @width
		
		@$el.children().css
			height: @height
			width: @width

		@_generateBackground()
		@_generateCross()
		@_setGlobalEvents()
		
		@_heatmap = h337.create
			element: @el
			radius: 8
			visible: false
		@_heatmap.get('canvas').style.zIndex = 0
		return @
