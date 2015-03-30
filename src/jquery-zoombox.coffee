( ($) ->
	$.fn.zoomBox = (options)->
		settings = $.extend {
				'dev'			: false			# is developer envoirment? (trace msgs)
				'clickToggle'	: true			# clicking box toggles zoom mode
				'zoomRanges'	: 1				# + / - controls added if > 1
				'zoomInLabel'	: '+'			# zoom in label
				'zoomOutLabel'	: '-'			# zoom out label
				'draggable'		: false			# drag !depends on jquery-ui Draggable!
			}, options
		$zb = this
		$img = null
		$zoomControls = null
		$zoomIn = null
		$zoomOut = null
		startX = 0
		startY = 0
		zoomRange = settings.zoomRanges
		oryginalImageWidth = 0
		
		# console.info if dev = true #
		trace = (str)->
			if settings.dev
				console.info(str)

		toggleMode = ()->			
			if $zb.hasClass('zb-error')
				trace ('cannot toggle; the image was not found!')
				return
			trace ("zoom image toggle mode")
			if $zb.hasClass('zb-zoom-on')
				zoomOff()
			else
				zoomOn()

		modeChangeStart = ()->
			$zb.addClass('zb-processing');
		
		modeChangeStop = ()->
			$zb.removeClass('zb-processing');
		
		zoomOff = ()->
			trace "zoom off"
			modeChangeStart()
			removeZoomRangeControls()
			$zb.removeClass('zb-zoom-on')
			removeEventListeners()
			modeChangeStop()
		
		zoomOn = ()->
			trace "zoom on"
			modeChangeStart()
			if $zb.hasClass('zb-loaded')
				readyToZoom()
			else
				loadFullImage( readyToZoom )

		readyToZoom = ()->
			trace "ready to zoom"
			addZoomRangeControls()
			addEventListeners()
			moveImage(startX, startY)
			$zb.addClass('zb-zoom-on')

		addEventListeners = ()->
			trace "add event listeners"
			if settings.draggable
				imageDraggable()				
			else
				$zb.on "mousemove", onMouseMove

		removeEventListeners = ()->
			trace "remove event listeners"
			$zb.off "mousemove", onMouseMove

		getFullImageSrc = ()->
			return $zb.data "zoom-src"

		loadFullImage = (callback)->			
			$zb.addClass "zb-loading"
			src = getFullImageSrc()
			trace "load full image " + src
			img = new Image()
			img.onload = ()->
				trace "image load complete"
				$zb.removeClass "zb-loading"
				$zb.addClass "zb-loaded"
				$img = $('<img src="' + src + '" alt="" class="zb-full" />')
				$zb.append $img
				oryginalImageWidth = $img.width()
				setOryginalImageWidth()
				# callback ? #
				if typeof callback is "function"
					callback()
			img.onerror = ()->
				trace "cannot load image " + src
				$zb.addClass "zb-error"
			img.src = src

		# Draggable #
		imageDraggable = ()->
			$img.draggable({containment: getBounds()});

		getBounds = ()->
			difX = $img.width() - $zb.width()
			difY = $img.height() - $zb.height()
			x2 = $zb.offset().left
			y2 = $zb.offset().top
			x1 = x2 - difX
			y1 = y2 - difY

			arr = [x1, y1, x2, y2]
			trace arr
			return arr


		# MouseMove #
		onMouseMove = (e)->			
			moveImage(e.pageX, e.pageY)

		moveImage = (mouseAbsoluteX, mouseAbsoluteY)->
			if not $img
				return			
			mouseX = mouseAbsoluteX - $zb.offset().left
			mouseY = mouseAbsoluteY - $zb.offset().top
			# trace "x: " + mouseX + " y: " + mouseY
			imgW = $img.width();
			imgH = $img.height();
			boxW = $zb.width();
			boxH = $zb.height();
			if boxW > imgW or boxH > imgH
				trace "full image can't be smaller then the box"
				return
			myX = mouseX / boxW * (imgW - boxW)
			myY = mouseY / boxH * (imgH - boxH)
			$img.css "left", -myX + "px"
			$img.css "top", -myY + "px"

		# public toggle #
		$.fn.zoomBox.toggle = ()->
			toggleMode()


		# create zoom range +/- controls and add event listeners #
		addZoomRangeControls = ()->
			if settings.zoomRanges < 2
				return false;	
			buildZoomRangeControls()
			updateZoomRangeControlsState()
			addZoomEventListeners()
			updateFullImageWidth()
		# build +/- #
		buildZoomRangeControls = ()->
			$zoomControls = $('<div class="zb-zoom-controls"></div>')
			$zoomIn = $('<div class="zb-zoom-control zb-zoom-in">' + settings.zoomInLabel + '</div>')
			$zoomOut = $('<div class="zb-zoom-control zb-zoom-out">' + settings.zoomOutLabel + '</div>')
			$zoomControls.append($zoomIn)
			$zoomControls.append($zoomOut)
			$zb.append($zoomControls)
		# remove +/- , reset zoomRange to 1 #
		removeZoomRangeControls = ()->
			if settings.zoomRanges < 2
				return false
			zoomRange = settings.zoomRanges
			$zoomIn.remove()
			$zoomOut.remove()
			$zoomControls.remove()

		# zoom range controls +/- event listeners #
		addZoomEventListeners = ()->
			$zoomIn.on "click", (e)->
				e.preventDefault()
				e.stopPropagation()
				zoomIn()
			$zoomOut.on "click", (e)->
				e.preventDefault()
				e.stopPropagation()
				zoomOut()
		
		
		# zoom in #
		zoomIn = ()->
			if zoomRange == 1
				return false
			zoomRange--
			trace "zoom in: " + zoomRange
			updateFullImageWidth()
			updateZoomRangeControlsState()
			if (settings.draggable)
				updateDraggable()

		# zoom out #
		zoomOut = ()->
			if zoomRange == settings.zoomRanges
				return false
			zoomRange++
			trace "zoom out: " + zoomRange
			updateFullImageWidth()
			updateZoomRangeControlsState()
			if (settings.draggable)
				updateDraggable()

		# set oryginal image width #
		setOryginalImageWidth = ()->
			return $img.css "width", oryginalImageWidth + "px"	

		# update full image width - zoomRange #
		updateFullImageWidth = ()->
			if zoomRange == 1
				return setOryginalImageWidth()
			dif = oryginalImageWidth - ($zb.width() + (oryginalImageWidth - $zb.width()) * 0.1);
			leap = dif / settings.zoomRanges
			w = oryginalImageWidth - leap * zoomRange
			$img.css "width", w + "px"			


		# zoom range controls +/- state .active
		updateZoomRangeControlsState = ()->
			if zoomRange == 1
				$zoomIn.removeClass('active')
			else
				$zoomIn.addClass('active')
			
			if zoomRange == settings.zoomRanges
				$zoomOut.removeClass('active')
			else
				$zoomOut.addClass('active')

		updateDraggable = ()->
			imageDraggable()

		# on click ? #
		if settings.clickToggle
			$zb.on "click", (e)->
				e.preventDefault()
				startX = e.pageX
				startY = e.pageY
				toggleMode()

		# init #
		init = ()->
			trace "ZoomBox!"

		init()
) jQuery