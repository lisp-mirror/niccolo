<script src="<!-- TMPL_VAR path-prefix -->/js/misc.js"></script>

<script>
    // Shorthand for $( document ).ready()
    $(function () {
	function sum2DVec (a, b){
	    return new Array(a[0] + b[0],
			     a[1] + b [1]);
	}

	function vecLength (a){
	    return Math.sqrt(a[0] * a[0] + a[1] * a[1]);
	}

	function vecDiff (a, b){
	    return new Array(a[0] - b[0],
			     a[1] - b [1]);

	}

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

	    this.width = function(){
		return this.lr[0] - this.ul[0];
	    }

	    this.height = function(){
		return this.lr[1] - this.ul[1];
	    }

	    this.center = function(x, y){
		let w = this.width(),
		    h = this.height();
		return new Array(this.ul[0] + w / 2,
				 this.ul[1] + h / 2);

	    };

	    this.translate = function(dx, dy){
		this.ul[0] += dx;
		this.lr[0] += dx;
		this.ul[1] += dy;
		this.lr[1] += dy;
	    };

	    this.scale = function(sx, sy){
		let center = this.center();
		this.translate(-center[0], -center[1]);
		this.ul[0] *= sx;
		this.lr[0] *= sx;
		this.ul[1] *= sy;
		this.lr[1] *= sy;
		this.translate(center[0], center[1]);
	    };


	};

	var canvasW               = 1024;
	var canvasH               = 768;
	var radius                = canvasW / 100.0;
	var statusErrorRe         = new RegExp("error");
	var statusOkRe            = new RegExp("ok");
	var statusOkColorInner    = "#00ff00";
	var statusOkColorOuter    = "#003300";
	var statusErrorColorInner = "#CD0A0A";
	var statusErrorColorOuter = "#660000";
	var statusErrorColorText  = "#ffffff";
	var statusOkColorText     = "#000000";
	var fontBalloon           = "18px Mono";

	var dpThreshold = 1e-3;
	var frictionK   = 0.7;
	var balloonMass = 1.0;
	var balloonAcel = new Array(0.0, 0.0);
	var balloonV    = new Array(0.0, 0.0);
	var balloonPos  = new Array(0.0, 0.0);

	var allAABB = [];

	$("#map").attr('width' , canvasW);
	$("#map").attr('height', canvasH);

	var mapBgURL       = "<!-- TMPL_VAR path-prefix -->/get-map/<!-- TMPL_VAR map-id -->";
	var sensorsDataURL = "<!-- TMPL_VAR sensors-data-url -->";
	var mapBg          = new Image();

	var canvas         = $("#map").get(0);
	var context = canvas.getContext('2d');

	function resetIntegrationParams(){
	    balloonAcel = new Array(0.0, 0.0),
	    balloonV    = new Array(0.0, 0.0),
	    balloonPos  = new Array(0.0, 0.0);
	}

	function integration(f, m, v, dt){
	    let reduceFn    = function (a, b) {
                               let bF = b(balloonPos, balloonAcel, balloonV, dt);
		                 return sum2DVec(a, bF);
	                     },
                totalForce  = f.reduce(reduceFn, new Array (0.0, 0.0));
	        a           = new Array(totalForce[0] / m, totalForce[1] / m),
                dv          = sum2DVec(balloonV, new Array(a[0] * dt, a[1] * dt)),
                dp          = new Array(dv[0] * dt, dv[1] * dt);
	        balloonAcel = a;
	        balloonV    = dv.slice();
	        balloonPos  = sum2DVec(balloonPos, dp);
	    return dp;
	}

	function  makeBalloon(canvas, context,
			      xSensor, ySensor,
			      desc, status, value, date){
	    context.font         = fontBalloon;
	    context.textBaseline = 'top';

	    let descMetrics    = context.measureText(desc),
	        statusMetrics  = context.measureText(status),
	        valueMetrics   = context.measureText(value),
	        dateMetrics    = context.measureText(date),
	        w              = Math.max(Math.max(statusMetrics.width,
						  valueMetrics.width),
					 Math.max(dateMetrics.width,
						  descMetrics.width)) + 10,
	        h              = 18 * 6;
	        balloonPos     = [xSensor - (w / 2), ySensor + 0.12 * h],
	        allSensorsData = null,
	        forces         = new Array(function (p, a, v, dt) {
		                            return new Array( Math.max(0.0, - 0.99 * p[0]),
							      Math.max(0.0, - 1.1 * p[1]));
	                                   },

				           function (p, a, v, dt) {
		                               return new Array( Math.min(0.0, -((0.99 * p[0] + w) -
										 canvasW)),
								 Math.min(0.0, -((p[1] + h) -
										 canvasH)));
	                                   },

				           function (p, a, v, dt) {
		                               return new Array( - v[0] * frictionK,
								 - v[1] * frictionK);
					   }),
	        dp               = integration(forces, balloonMass, balloonV, 0.5);


	    while (vecLength(dp) > dpThreshold){
		dp = integration(forces, balloonMass, balloonV, 0.5);
	    }

	    context.fillStyle   = '#ffffff';
	    context.strokeStyle = '#000000';

	    if(statusErrorRe.test(status)){
		context.fillStyle   = statusErrorColorInner;
		context.strokeStyle = statusErrorColorOuter;
	    }

	    let lr         = [ balloonPos[0] + w, balloonPos[1] + h ],
		arrowEnds  = [lr[0], balloonPos[1]],
	        aabbArrow  = new AABB();

	    aabbArrow.expand(balloonPos[0], balloonPos[1]);
	    aabbArrow.expand(lr[0], lr[1]);
	    aabbArrow.scale(0.3, 0.8);
            context.lineWidth   = 2;

	    context.beginPath();
	    context.moveTo(xSensor, ySensor);
	    context.lineTo(aabbArrow.ul[0], aabbArrow.ul[1]);
	    context.lineTo(aabbArrow.ul[0], aabbArrow.lr[1]);
	    context.lineTo(aabbArrow.lr[0], aabbArrow.lr[1]);
	    context.lineTo(aabbArrow.lr[0], aabbArrow.ul[1]);
	    context.closePath();
	    context.fill();


	    context.beginPath();
	    context.rect(balloonPos[0], balloonPos[1], w, h);
	    context.closePath();
	    context.fill();

	    // draw text
	    context.fillStyle    = statusOkColorText;
	    if(statusErrorRe.test(status)){
		context.fillStyle    = statusErrorColorText;

	    }
	    context.fillText(desc,   balloonPos[0] + 5, balloonPos[1] + 5);
	    context.fillText(status, balloonPos[0] + 5, balloonPos[1] + 5 + 25);
	    context.fillText(value,  balloonPos[0] + 5, balloonPos[1] + 5 + 50);
	    context.fillText(date,   balloonPos[0] + 5, balloonPos[1] + 5 + 75);
	}

	canvas.addEventListener('click', function(event) {
	    resetIntegrationParams();
	    let x = event.offsetX,
		y = event.offsetY;
	    redrawLoop();
	    for (var i = 0; i < allAABB.length; i++) {
		if(allAABB[i].inside(x, y)){
		    let center = allAABB[i].center();
		    makeBalloon(this, context, center[0], center[1],
				allSensorsData[i].description,
			        "Status: "      + allSensorsData[i].status,
				"Last value: "  + allSensorsData[i].lastValue,
				"Last access: " + allSensorsData[i].lastAccessTime);
		    break;
		}
	    }
	});

	function loadSensorsData() {
	    $.ajax({
		url:        sensorsDataURL,
	    }).done(function( data ) {
		var processSensorFn = function (sensor, index, array) {
		    let centerX = sensor["sCoord"] * canvasW,
		        centerY = sensor["tCoord"] * canvasH;
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
		    let aabbSensor = new AABB();
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

	window.setInterval(redrawLoop, 60000);
    })
</script>

<!-- TMPL_INCLUDE 'back-button.tpl' -->

<canvas id="map"></canvas>
