<script src="<!-- TMPL_VAR path-prefix -->/js/place-footer.js"></script>

<script>
    // Shorthand for $( document ).ready()
    $(function() {
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

	    return bgColor;
	}

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
		url:    "<!-- TMPL_VAR service-link -->",
		method: "POST",
		data: { req: jj }
	    }).success(function( data ) {
		let info = JSON.parse(data),
		    tplView = {},
		    tpl     = "<tr>"                                   +
		    "<td>{{rPhrases}}</td>"                            +
		    "<td>{{expositionTypes}}</td>"                     +
		    "<td>{{physicalState}}</td>"                       +
		    "<td>{{workingTemp}}</td>"                         +
		    "<td>{{boilingPoint}}</td>"                        +
		    "<td>{{expositionTimeType}}</td>"                  +
		    "<td>{{expositionTime}}</td>"                      +
		    "<td>{{usage}}</td>"                               +
		    "<td>{{quantityUsed}}</td>"                        +
		    "<td>{{quantityStocked}}</td>"                     +
		    "<td>{{workType}}</td>"                            +
		    "<td>{{protectionsFactor}}</td>"                   +
		    "<td>{{safetyThreshold}}</td>"                     +
		    "<td style=\"background: {{bgRes}}\">{{res}}</td>" +
		    "<td >{{err}}</td>"                                +
		    "</tr>";
		tplView.rPhrases           = obj.rPhrases;
		tplView.expositionTypes    = obj.expositionTypes;
		tplView.physicalState      = obj.physicalState;
		tplView.workingTemp        = obj.workingTemp;
		tplView.boilingPoint       = obj.boilingPoint;
		tplView.expositionTimeType = obj.expositionTimeType;
		tplView.expositionTime     = obj.expositionTime;
		tplView.usage              = obj.usage;
		tplView.quantityUsed       = obj.quantityUsed;
		tplView.quantityStocked    = obj.quantityStocked;
		tplView.workType           = obj.workType;
		tplView.protectionsFactor  = obj.protectionsFactor;
		tplView.safetyThreshold    = obj.safetyThreshold;
		tplView.bgRes              = colorizeRes(info.res);
		tplView.res                = info.res;
		tplView.err                = info.err;
		$( "#results" ).append(Mustache.render(tpl,tplView));
		placeFooter();
	    }).error(function( data ) {
		$( "#results" ).append("<tr><td>" + "ERROR" + "</td></tr>");
		placeFooter();
	    });
	});
    });
</script>

    <label for="r-phrases"><!-- TMPL_VAR h-phrase-lb --></label>
    <select id="r-phrases" multiple>
      <!-- TMPL_LOOP option-h-codes -->
      <option value="<!-- TMPL_VAR h-code -->"><!-- TMPL_VAR h-code --></option>
      <!-- /TMPL_LOOP  -->
    </select>
    <label for="exp-types"><!-- TMPL_VAR exposition-types-lb --></label>
    <select id="exp-types" multiple>
      <!-- TMPL_LOOP option-exp-types -->
      <option value="<!-- TMPL_VAR exp-type -->"><!-- TMPL_VAR exp-type --></option>
      <!-- /TMPL_LOOP  -->
    </select>
    <label for="phys-states"><!-- TMPL_VAR physical-state-lb --></label>
    <select id="phys-states">
      <!-- TMPL_LOOP option-phys-states -->
      <option value="<!-- TMPL_VAR phys-state -->"><!-- TMPL_VAR phys-state --></option>
      <!-- /TMPL_LOOP  -->
    </select>
    <label for="working-temp"><!-- TMPL_VAR working-temp-lb --></label>
    <input type="text" id="working-temp" value="25"/>
    <label for="boiling-point"><!-- TMPL_VAR boiling-point-lb --></label>
    <input type="text" id="boiling-point" value="100"/>
    <label for="exp-time-type"><!-- TMPL_VAR exposition-time-type-lb --></label>
    <select id="exp-time-type">
      <!-- TMPL_LOOP option-exp-time-type -->
      <option value="<!-- TMPL_VAR exp-time-type -->"><!-- TMPL_VAR exp-time-type --></option>
      <!-- /TMPL_LOOP  -->
    </select>
    <label for="esposition-time"><!-- TMPL_VAR exposition-time-lb --></label>
    <input type="text" id="exposition-time" value="100"/>
    <label for="usage"><!-- TMPL_VAR usage-lb --></label>
    <select id="usage">
      <!-- TMPL_LOOP option-usages -->
      <option value="<!-- TMPL_VAR usage -->"><!-- TMPL_VAR usage --></option>
      <!-- /TMPL_LOOP  -->
    </select>
    <label for="quantity-used"><!-- TMPL_VAR quantity-used-lb --></label>
    <input type="text" id="quantity-used" value="0.0" />
    <label for="quantity-stocked"><!-- TMPL_VAR quantity-stocked-lb --></label>
    <input type="text" id="quantity-stocked" value="0.0" />
    <label for="work-type"><!-- TMPL_VAR work-type-lb --></label>
    <select id="work-type">
      <!-- TMPL_LOOP option-work-types -->
      <option value="<!-- TMPL_VAR work-type -->"><!-- TMPL_VAR work-type --></option>
      <!-- /TMPL_LOOP  -->
    </select>
    <label for="protection-factors"><!-- TMPL_VAR protection-factors-lb --></label>
    <select id="protection-factors" multiple>
      <!-- TMPL_LOOP option-protection-factors -->
      <option value="<!-- TMPL_VAR protection-factor -->"><!-- TMPL_VAR protection-factor -->
      </option>
      <!-- /TMPL_LOOP  -->
    </select>
    <label for="safety-threshold">
      <!-- TMPL_VAR safety-threshold-lb --> ( g/(m<sup>3</sup> * h) )
    </label>
    <input type="text" id="safety-threshold" value="0.1" />
    <input id="start" type="submit" value="Calculate" />

    <!-- TMPL_INCLUDE 'back-button.tpl' -->

    <table id="results">
      <tr>
	<th>
	  <!-- TMPL_VAR h-phrase-lb -->
	</th>
	<th>
	  <!-- TMPL_VAR exposition-types-lb -->
	</th>
	<th>
	  <!-- TMPL_VAR physical-state-lb -->
	</th>
	<th>
	  <!-- TMPL_VAR working-temp-lb -->
	</th>
	<th>
	  <!-- TMPL_VAR boiling-point-lb -->
	</th>
	<th>
	  <!-- TMPL_VAR exposition-time-type-lb -->
	</th>
	<th>
	  <!-- TMPL_VAR exposition-time-lb -->
	</th>
	<th>
	  <!-- TMPL_VAR usage-lb -->
	</th>
	<th>
	  <!-- TMPL_VAR quantity-used-lb -->
	</th>
	<th>
	  <!-- TMPL_VAR quantity-stocked-lb -->
	</th>
	<th>
	  <!-- TMPL_VAR work-type-lb -->
	</th>
	<th>
	  <!-- TMPL_VAR protection-factors-lb -->
	</th>
	<th>
	  <!-- TMPL_VAR safety-threshold-lb -->
	</th>
	<th>
	  <!-- TMPL_VAR results-lb -->
	</th>
	<th>
	  <!-- TMPL_VAR errors-lb -->
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
