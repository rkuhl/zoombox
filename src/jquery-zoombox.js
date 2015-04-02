// Generated by CoffeeScript 1.8.0
(function() {
  (function($) {
    return $.fn.zoomBox = function(options) {
      var $img, $zb, $zoomControls, $zoomIn, $zoomOut, addEventListeners, addZoomEventListeners, addZoomRangeControls, buildZoomRangeControls, getBounds, getFullImageSrc, imageDraggable, init, isImageInBounds, loadFullImage, modeChangeStart, modeChangeStop, moveImage, onMouseMove, oryginalImageWidth, readyToZoom, removeEventListeners, removeZoomRangeControls, resetImagePosition, setOryginalImageWidth, settings, startX, startY, toggleMode, trace, updateDraggable, updateFullImageWidth, updateZoomRangeControlsState, zoomIn, zoomOff, zoomOn, zoomOut, zoomRange;
      settings = $.extend({
        'dev': false,
        'clickToggle': true,
        'zoomRanges': 1,
        'zoomInLabel': '+',
        'zoomOutLabel': '-',
        'draggable': false
      }, options);
      $zb = this;
      $img = null;
      $zoomControls = null;
      $zoomIn = null;
      $zoomOut = null;
      startX = 0;
      startY = 0;
      zoomRange = settings.zoomRanges;
      oryginalImageWidth = 0;
      trace = function(str) {
        if (settings.dev) {
          return console.info(str);
        }
      };
      toggleMode = function() {
        if ($zb.hasClass('zb-error')) {
          trace('cannot toggle; the image was not found!');
          return;
        }
        trace("zoom image toggle mode");
        if ($zb.hasClass('zb-zoom-on')) {
          return zoomOff();
        } else {
          return zoomOn();
        }
      };
      modeChangeStart = function() {
        return $zb.addClass('zb-processing');
      };
      modeChangeStop = function() {
        return $zb.removeClass('zb-processing');
      };
      zoomOff = function() {
        trace("zoom off");
        modeChangeStart();
        removeZoomRangeControls();
        $zb.removeClass('zb-zoom-on');
        removeEventListeners();
        return modeChangeStop();
      };
      zoomOn = function() {
        trace("zoom on");
        modeChangeStart();
        if ($zb.hasClass('zb-loaded')) {
          return readyToZoom();
        } else {
          return loadFullImage(readyToZoom);
        }
      };
      readyToZoom = function() {
        trace("ready to zoom");
        addZoomRangeControls();
        addEventListeners();
        moveImage(startX, startY);
        return $zb.addClass('zb-zoom-on');
      };
      addEventListeners = function() {
        trace("add event listeners");
        if (settings.draggable) {
          return imageDraggable();
        } else {
          return $zb.on("mousemove", onMouseMove);
        }
      };
      removeEventListeners = function() {
        trace("remove event listeners");
        return $zb.off("mousemove", onMouseMove);
      };
      getFullImageSrc = function() {
        return $zb.data("zoom-src");
      };
      loadFullImage = function(callback) {
        var img, src;
        $zb.addClass("zb-loading");
        src = getFullImageSrc();
        trace("load full image " + src);
        img = new Image();
        img.onload = function() {
          trace("image load complete");
          $zb.removeClass("zb-loading");
          $zb.addClass("zb-loaded");
          $img = $('<img src="' + src + '" alt="" class="zb-full" />');
          $zb.append($img);
          oryginalImageWidth = $img.width();
          setOryginalImageWidth();
          if (typeof callback === "function") {
            return callback();
          }
        };
        img.onerror = function() {
          trace("cannot load image " + src);
          return $zb.addClass("zb-error");
        };
        return img.src = src;
      };
      imageDraggable = function() {
        return $img.draggable({
          containment: getBounds()
        });
      };
      getBounds = function() {
        var difX, difY, x1, x2, y1, y2;
        difX = $img.width() - $zb.width();
        difY = $img.height() - $zb.height();
        x2 = $zb.offset().left;
        y2 = $zb.offset().top;
        x1 = x2 - difX;
        y1 = y2 - difY;
        return [x1, y1, x2, y2];
      };
      isImageInBounds = function() {
        var bounds, imgX, imgY;
        bounds = getBounds();
        imgX = $img.offset().left;
        imgY = $img.offset().top;
        if (imgX < bounds[0] || imgX > bounds[2] || imgY < bounds[1] || imgY > bounds[3]) {
          return false;
        }
        return true;
      };
      resetImagePosition = function() {
        var bounds, imgX, imgY;
        if (!isImageInBounds()) {
          bounds = getBounds();
          imgX = $img.offset().left;
          imgY = $img.offset().top;
          if (imgX < bounds[0]) {
            $img.css("left", bounds[0] + "px");
          }
          if (imgX > bounds[2]) {
            $img.css("left", bounds[2] + "px");
          }
          if (imgY < bounds[1]) {
            $img.css("top", bounds[1] + "px");
          }
          if (imgY > bounds[3]) {
            return $img.css("top", bounds[3] + "px");
          }
        }
      };
      onMouseMove = function(e) {
        return moveImage(e.pageX, e.pageY);
      };
      moveImage = function(mouseAbsoluteX, mouseAbsoluteY) {
        var boxH, boxW, imgH, imgW, mouseX, mouseY, myX, myY;
        if (!$img) {
          return;
        }
        mouseX = mouseAbsoluteX - $zb.offset().left;
        mouseY = mouseAbsoluteY - $zb.offset().top;
        imgW = $img.width();
        imgH = $img.height();
        boxW = $zb.width();
        boxH = $zb.height();
        if (boxW > imgW || boxH > imgH) {
          trace("full image can't be smaller then the box");
          return;
        }
        myX = mouseX / boxW * (imgW - boxW);
        myY = mouseY / boxH * (imgH - boxH);
        $img.css("left", -myX + "px");
        return $img.css("top", -myY + "px");
      };
      $.fn.zoomBox.toggle = function() {
        return toggleMode();
      };
      addZoomRangeControls = function() {
        if (settings.zoomRanges < 2) {
          return false;
        }
        buildZoomRangeControls();
        updateZoomRangeControlsState();
        addZoomEventListeners();
        return updateFullImageWidth();
      };
      buildZoomRangeControls = function() {
        $zoomControls = $('<div class="zb-zoom-controls"></div>');
        $zoomIn = $('<div class="zb-zoom-control zb-zoom-in">' + settings.zoomInLabel + '</div>');
        $zoomOut = $('<div class="zb-zoom-control zb-zoom-out">' + settings.zoomOutLabel + '</div>');
        $zoomControls.append($zoomIn);
        $zoomControls.append($zoomOut);
        return $zb.append($zoomControls);
      };
      removeZoomRangeControls = function() {
        if (settings.zoomRanges < 2) {
          return false;
        }
        zoomRange = settings.zoomRanges;
        $zoomIn.remove();
        $zoomOut.remove();
        return $zoomControls.remove();
      };
      addZoomEventListeners = function() {
        $zoomIn.on("click", function(e) {
          e.preventDefault();
          e.stopPropagation();
          return zoomIn();
        });
        return $zoomOut.on("click", function(e) {
          e.preventDefault();
          e.stopPropagation();
          return zoomOut();
        });
      };
      zoomIn = function() {
        if (zoomRange === 1) {
          return false;
        }
        zoomRange--;
        trace("zoom in: " + zoomRange);
        updateFullImageWidth();
        updateZoomRangeControlsState();
        if (settings.draggable) {
          return updateDraggable();
        }
      };
      zoomOut = function() {
        if (zoomRange === settings.zoomRanges) {
          return false;
        }
        zoomRange++;
        trace("zoom out: " + zoomRange);
        updateFullImageWidth();
        updateZoomRangeControlsState();
        if (settings.draggable) {
          return updateDraggable();
        }
      };
      setOryginalImageWidth = function() {
        return $img.css("width", oryginalImageWidth + "px");
      };
      updateFullImageWidth = function() {
        var dif, leap, w;
        if (zoomRange === 1) {
          return setOryginalImageWidth();
        }
        dif = oryginalImageWidth - ($zb.width() + (oryginalImageWidth - $zb.width()) * 0.1);
        leap = dif / settings.zoomRanges;
        w = oryginalImageWidth - leap * zoomRange;
        $img.css("width", w + "px");
        return resetImagePosition();
      };
      updateZoomRangeControlsState = function() {
        if (zoomRange === 1) {
          $zoomIn.removeClass('active');
        } else {
          $zoomIn.addClass('active');
        }
        if (zoomRange === settings.zoomRanges) {
          return $zoomOut.removeClass('active');
        } else {
          return $zoomOut.addClass('active');
        }
      };
      updateDraggable = function() {
        $img.draggable('destroy');
        return imageDraggable();
      };
      if (settings.clickToggle) {
        $zb.on("click", function(e) {
          e.preventDefault();
          startX = e.pageX;
          startY = e.pageY;
          return toggleMode();
        });
      }
      init = function() {
        return trace("ZoomBox!");
      };
      return init();
    };
  })(jQuery);

}).call(this);
