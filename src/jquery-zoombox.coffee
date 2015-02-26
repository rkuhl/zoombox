( ($) ->
	$.fn.zoomBox = (options)->
		settings = $.extend {
				'dev'			: false			# is developer envoirment? (trace msgs)
				'clickToggle'	: true			# clicking box toggles zoom mode
			}, options
		$zb = this
		$img = null
		startX = 0
		startY = 0
		
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
			addEventListeners()
			moveImage(startX, startY)
			$zb.addClass('zb-zoom-on')

		addEventListeners = ()->
			trace "add event listeners"
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
				# callback ? #
				if typeof callback is "function"
					callback()
			img.onerror = ()->
				trace "cannot load image " + src
				$zb.addClass "zb-error"
			img.src = src


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