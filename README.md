jquery-zoombox.js
===========
jQuery plugin that will let you preview a zoomed image within a box.  
Reference: [Canyon.com](https://www.canyon.com/en/mountainbikes/bike.html?b=3665)
by [Roman Kühl](http://www.kuhl.pl).  

Example
---
HTML:    
```html
<script src="jquery.js" type="text/javascript"></script>  
<script src="jquery-zoombox.js" type="text/javascript"></script>
<div id="zoom-box" data-zoom-src="large-image.jpg"></div>
```  
CSS:    
```css
#zoom-box {
	overflow: hidden;
	position: relative;
}
#zoom-box img.zb-full {
	display: none;
	position: absolute;
}
#zoom-box.zb-zoom-on img.zb-full {
	display: block;
}
```  
JS:  
```javascript
$(document).ready(function() {
	$("#zoom-box").zoomBox();
});
```
Options
---
```clickToggle``` if false the box is not clickable, default true   
```zoomRanges``` if more than 1 zoom + / - controls are added, default 1   
```zoomInLabel``` zoom in label, default '+'   
```zoomOutLabel``` zoom out label, default '-'   
```dev``` if true some messages are logged into the console  

Example 2
---
CSS:    
```css
#zoom-box {
	width: 700px;
	height: 400px;
	overflow: hidden;
	background: #ececec url('../assets/s.jpg') no-repeat 50% 50%;
	background-size: cover;
	cursor: pointer;
	position: relative;
}
#zoom-box img.zb-full {
	display: none;
	position: absolute;
}
#zoom-box.zb-zoom-on img.zb-full {
	display: block;
}
.zb-zoom-controls {
	position: absolute;
	z-index: 2;
}
.zb-zoom-control {
	text-align: center;
	width: 10px;	
	padding: 2px 6px;
	margin: 5px;
	background-color: rgba(255,255,255,.5);
	cursor: default;
}
.zb-zoom-control.active {
	background-color: white;
	cursor: pointer;
}
```  
JS:  
```javascript
$(document).ready(function() {
	$("#zoom-box").zoomBox({
		clickToggle: true,
		zoomRanges: 4,
		zoomInLabel: 'zoom in',
		zoomOutLabel: 'zoom out',
		dev: true
	});
});
```
