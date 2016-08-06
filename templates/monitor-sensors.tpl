<script src="<!-- TMPL_VAR path-prefix -->/js/misc.js"></script>

<script>
    // Shorthand for $( document ).ready()
    $(function () {

	function AABB() {
	    this.id = -1;

	    this.ul = new Array(1e6, 1e6);

	    this.lr = new Array(-1.0, -1.0);

	     this.expand = function (x, y){
		if (x <= this.ul[0]){
		    this.ul[0] = x;
		}

		if (y <= this.ul[1]){
		    this.ul[1] = y;
		}

		if (x >= this.lr[0]){
		    this.lr[0] = x;
		}

		if (y >= this.lr[1]){
		    this.lr[1] = y;
		}

	    };

	    this.inside = function(x, y){
		return x >= this.ul[0] &&
		    x <=  this.lr[0] &&
		    y <=  this.lr[1] &&
		    y >= this.ul[1];
	    };

	    this.center = function(x, y){
		var w = this.lr[0] - this.ul[0];
		var h = this.lr[1] - this.ul[1];
		return new Array(this.ul[0] + w / 2,
				 this.ul[1] + h / 2);

	    };


	};

	var canvasW               = 1024;
	var canvasH               = 768;
	var radius                = canvasW / 100.0;
	var statusErrorRe         = new RegExp("error");
	var statusOkRe            = new RegExp("ok");
	var statusOkColorInner    = "#00ff00";
	var statusOkColorOuter    = "#003300";
	var statusErrorColorInner = "#ff0000";
	var statusErrorColorOuter = "#660000";
	var fontBalloon           = "18px Mono";

	var allAABB = [];

	$("#map").attr('width' , canvasW);
	$("#map").attr('height', canvasH);

	var mapBgURL       = "<!-- TMPL_VAR path-prefix -->/get-map/<!-- TMPL_VAR map-id -->";
	var sensorsDataURL = "<!-- TMPL_VAR sensors-data-url -->";
	var mapBg          = new Image();

	var canvas         = $("#map").get(0);

	function  makeBalloon(canvas, context, h,
			      xSensor, ySensor,
			      desc, status, value, date){
	    context.font         = fontBalloon;
	    context.textBaseline = 'top';

	    var descMetrics   = context.measureText(desc);
	    var statusMetrics = context.measureText(status);
	    var valueMetrics  = context.measureText(value);
	    var dateMetrics   = context.measureText(date);

	    var w = Math.max(Math.max(statusMetrics.width,
				      valueMetrics.width),
			     Math.max(dateMetrics.width,
				      descMetrics.width)) + 10;
	    var h  = 18 * 6;
	    var ul = [(canvasW / 2) - (w / 2), (canvasH / 2) - (h / 2)];
	    var lr = [(canvasW / 2) + (w / 2), (canvasH / 2) + (h / 2)];
	    var a  = [lr[0], ul[1]];
	    var allSensorsData = null;

	    context.fillStyle   = '#ffffff';
	    context.strokeStyle = '#000000';

	    if(statusErrorRe.test(status)){
		context.fillStyle   = statusErrorColorInner;
		context.strokeStyle = statusErrorColorOuter;
	    }


	    context.lineWidth   = 2;

	    context.beginPath();
	    context.moveTo(xSensor, ySensor);
	    context.lineTo(lr[0], lr[1]);
	    context.lineTo(a[0], a[1]);
	    context.closePath();

	    context.fill();
	    context.fillRect(ul[0], ul[1], w, h);

	    // draw text
	    context.fillStyle    = '#000000';
	    context.fillText(desc,   ul[0] + 5, ul[1] + 5);
	    context.fillText(status, ul[0] + 5, ul[1] + 5 + 25);
	    context.fillText(value,  ul[0] + 5, ul[1] + 5 + 50);
	    context.fillText(date,   ul[0] + 5, ul[1] + 5 + 75);
	}

	canvas.addEventListener('click', function(event) {
	    var x = event.offsetX;
	    var	y = event.offsetY;
	    redrawLoop();
	    for (var i = 0; i < allAABB.length; i++) {
		if(allAABB[i].inside(x, y)){
//		    alert(allAABB[i].id);
		    var center = allAABB[i].center();
		    makeBalloon(this, context, 200, center[0], center[1],
				allSensorsData[i].description,
			        "Status: "      + allSensorsData[i].status,
				"Last value: "  + allSensorsData[i].lastValue,
				"Last access: " + allSensorsData[i].lastAccessTime);
		    break;
		}
	    }
	});


	var context        = canvas.getContext('2d');



	function loadSensorsData() {
	    $.ajax({
		url: sensorsDataURL
	    }).done(function( data ) {
		var processSensorFn = function (sensor, index, array) {
		    var centerX = sensor["sCoord"] * canvasW;
		    var centerY = sensor["tCoord"] * canvasH;
		    // draw
		    context.beginPath();
		    context.arc(centerX, centerY, radius,
		 		0, 2 * Math.PI, false);

		    context.fillStyle   = statusOkColorInner;
		    context.strokeStyle = statusOkColorOuter;

		    if(statusErrorRe.test(sensor["status"])){
			context.fillStyle   = statusErrorColorInner;
			context.strokeStyle = statusErrorColorOuter;
		    }

		    context.fill();
		    context.lineWidth = 2;
		    context.stroke();

		    // calculate aabb
		    var aabbSensor = new AABB();
		    aabbSensor.expand(centerX - radius, centerY - radius);
		    aabbSensor.expand(centerX + radius, centerY + radius);
		    aabbSensor.id = sensor["sensorId"];
		    allAABB.push(aabbSensor);
		}
		allAABB = [];
		allSensorsData = JSON.parse(data);
		allSensorsData.forEach(processSensorFn);
	    });
	}

	function redrawLoop(){
	    context.drawImage(mapBg, 0, 0, canvasW, canvasH);
	    loadSensorsData();
	}

	mapBg.onload = function() {
	    redrawLoop();
	};

	mapBg.src = mapBgURL;

	window.setInterval(redrawLoop, 30000);
    })
</script>


<canvas id="map">

</canvas>
