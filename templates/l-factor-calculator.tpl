<script src="../js/place-footer.js"></script>

<script>
    // Shorthand for $( document ).ready()
    function colorizeRes (val){
	var bgColor ="#ffffff";

	if (val >= 0.001 &&
	    val < 0.01){
	    bgColor = "#00ff00";
	}else if (val >= 0.01 &&
		  val < 0.1){
	    bgColor = "#ffff00";
	}else if (val >= 0.1 &&
		  val < 1){
	    bgColor = "#ff7a00";
	}else if (val >= 1){
	    bgColor = "#ff0000";
	}

	return '<td style="background: ' + bgColor + ';' +   ' color: #000000">' +
	       val                                                               +
	       '</td>';
    }

    $(function() {
	$( "#start" ).on('click', function(e){
	    var extractText = function (a) { return $(a).text().trim(); }

	    function extractSelected (a) {
		return $.makeArray($(a).children( "option:selected" )).map(extractText);
	    }

	    var obj                = {};
	    obj.rPhrases           = extractSelected($( "#r-phrases" ));
	    obj.expositionTypes    = extractSelected($( "#exp-types" ));
	    obj.physicalState      = extractSelected($( "#phys-states" ));
	    obj.workingTemp        = $( "#working-temp" ).val().trim();
	    obj.boilingPoint       = $( "#boiling-point" ).val().trim();
	    obj.expositionTimeType = extractSelected($( "#exp-time-type" ));
	    obj.expositionTime     = $( "#exposition-time" ).val().trim();
	    obj.usage              = extractSelected($( "#usage" ));
	    obj.quantityUsed       = $( "#quantity-used" ).val().trim();
	    obj.quantityStocked    = $( "#quantity-stocked" ).val().trim();
	    obj.workType           = extractSelected($( "#work-type" ));
	    obj.protectionsFactor  = extractSelected($( "#protection-factors" ));
	    obj.safetyThreshold    = $( "#safety-threshold" ).val().trim();
	    var jj = JSON.stringify(obj);
	    $.ajax({
		url:    "<!-- TMPL_VAR path-prefix -->/l-factor/",
		method: "POST",
		data: { req: jj }
	    }).success(function( data ) {
		var info = JSON.parse(data);
		$( "#results" ).append("<tr>"                                    +
				       "<td>" + obj.rPhrases + "</td>"           +
				       "<td>" + obj.expositionTypes + "</td>"    +
				       "<td>" + obj.physicalState + "</td>"      +
				       "<td>" + obj.workingTemp + "</td>"        +
				       "<td>" + obj.boilingPoint + "</td>"       +
				       "<td>" + obj.expositionTimeType + "</td>" +
				       "<td>" + obj.expositionTime + "</td>"     +
				       "<td>" + obj.usage + "</td>"              +
				       "<td>" + obj.quantityUsed + "</td>"       +
				       "<td>" + obj.quantityStocked + "</td>"    +
				       "<td>" + obj.workType + "</td>"           +
				       "<td>" + obj.protectionsFactor + "</td>"  +
				       "<td>" + obj.safetyThreshold + "</td>"    +
		                       colorizeRes(info.res)                     +
				       "<td>" + info.err + "</td>"               +
				       "</tr>");
		placeFooter();
	    }).error(function( data ) {
		$( "#results" ).append("<tr><td>" + "ERROR" + "</td></tr>");
		placeFooter();
	    });
	});
    });
</script>

    <label for="r-phrases">H phrase</label>
    <select id="r-phrases" multiple>
      <!-- TMPL_LOOP option-h-codes -->
      <option value="<!-- TMPL_VAR h-code -->"><!-- TMPL_VAR h-code --></option>
      <!-- /TMPL_LOOP  -->
    </select>
    <label for="exp-types">Exposition types</label>
    <select id="exp-types" multiple>
      <!-- TMPL_LOOP option-exp-types -->
      <option value="<!-- TMPL_VAR exp-type -->"><!-- TMPL_VAR exp-type --></option>
      <!-- /TMPL_LOOP  -->
    </select>
    <label for="phys-states">Physical state</label>
    <select id="phys-states">
      <!-- TMPL_LOOP option-phys-states -->
      <option value="<!-- TMPL_VAR phys-state -->"><!-- TMPL_VAR phys-state --></option>
      <!-- /TMPL_LOOP  -->
    </select>
    <label for="working-temp">Working temperature (°C)</label>
    <input type="text" id="working-temp" value="25"/>
    <label for="boiling-point">Boiling point (°C)</label>
    <input type="text" id="boiling-point" value="100"/>
    <label for="exp-time-type">Exposition time type</label>
    <select id="exp-time-type">
      <!-- TMPL_LOOP option-exp-time-type -->
      <option value="<!-- TMPL_VAR exp-time-type -->"><!-- TMPL_VAR exp-time-type --></option>
      <!-- /TMPL_LOOP  -->
    </select>
    <label for="esposition-time">Exposition time (min)</label>
    <input type="text" id="exposition-time" value="100"/>
    <label for="usage">Usage</label>
    <select id="usage">
      <!-- TMPL_LOOP option-usages -->
      <option value="<!-- TMPL_VAR usage -->"><!-- TMPL_VAR usage --></option>
      <!-- /TMPL_LOOP  -->
    </select>
    <label for="quantity-used">Quantity used (g)</label>
    <input type="text" id="quantity-used" value="0.0" />
    <label for="quantity-stocked">Quantity stocked (g)</label>
    <input type="text" id="quantity-stocked" value="0.0" />
    <label for="work-type">Work type</label>
    <select id="work-type">
      <!-- TMPL_LOOP option-work-types -->
      <option value="<!-- TMPL_VAR work-type -->"><!-- TMPL_VAR work-type --></option>
      <!-- /TMPL_LOOP  -->
    </select>
    <label for="protection-factors">Protection factors</label>
    <select id="protection-factors" multiple>
      <!-- TMPL_LOOP option-protection-factors -->
      <option value="<!-- TMPL_VAR protection-factor -->"><!-- TMPL_VAR protection-factor -->
      </option>
      <!-- /TMPL_LOOP  -->
    </select>
    <label for="safety-threshold">Safety threshold ( g/(m<sup>3</sup> * h) )</label>
    <input type="text" id="safety-threshold" value="0.1" />
    <input id="start" type="submit" value="Calculate" />
    <table id="results">
      <tr>
	<th>
	  GHS Codes
	</th>
	<th>
	  Exposition types
	</th>
	<th>
	  Physical state
	</th>
	<th>
	  Working temperature
	</th>
	<th>
	  Boiling point
	</th>
	<th>
	  Exposition time type
	</th>
	<th>
	  Exposition time
	</th>
	<th>
	  Usage
	</th>
	<th>
	  Quantity used
	</th>
	<th>
	  Quantity stocked
	</th>
	<th>
	  Work type
	</th>
	<th>
	  Protection factor
	</th>
	<th>
	  Safety threshold
	</th>
	<th>
	  Results
	</th>
	<th>
	  Errors
	</th>
      </tr>
    </table>

<div class="biblio-ref">
  <div class="authors">
    ISPRA e ARPA Sicilia<br />
    Centro Interagenziale “Igiene e Sicurezza del Lavoro”
  </div>
  <div class="title">
    Linee guida per la valutazione del rischio da esposizione ad Agenti
    Chimici Pericolosi e ad Agenti Cancerogeni e Mutageni
  </div>
  <div class="publication">
    Manuali e Linee Guida 73/2011
  </div>
  <div class="biblio-id">
      ISBN: 978-88-448-0504-3
  </div>
</div>
