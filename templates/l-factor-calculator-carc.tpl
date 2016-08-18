<script>
    function colorizeRes (val){
	var bgColor ="#ff0000";

	if (val < 1){
	    bgColor = "#00ff00";
	}


	return '<td style="background: ' + bgColor + ';' +   ' color: #000000">' +
	    val                                                               +
	    '</td>';
    }

$(function() {
    $( "#start" ).click(function(e){
	var extractText = function (a) { return $(a).text().trim(); }

	function extractSelected (a) {
	    return $.makeArray($(a).children( "option:selected" )).map(extractText);
	}

	var obj                = {};
	obj.protectiveDevice   = extractSelected($( "#protective-devices" ));
	obj.physicalState      = extractSelected($( "#physical-states" ));
        obj.twork              = $( "#working-temp" ).val().trim();
        obj.teb                = $( "#boiling-point" ).val().trim();
	obj.quantityUsed       = $( "#quantity-used"  ).val().trim();
	obj.usagePerDay        = $( "#usage-per-day"  ).val().trim();
	obj.usagePerYear       = $( "#usage-per-year" ).val().trim();
	var jj = JSON.stringify(obj);
	$.ajax({
	    url:    "<!-- TMPL_VAR service-link -->",
	    method: "POST",
	    data: { req: jj }
	}).success(function( data ) {
	    var info = JSON.parse(data);
	    $( "#results" ).append("<tr>"                                   +
				   "<td>" + obj.protectiveDevice  + "</td>" +
				   "<td>" + obj.physicalState     + "</td>" +
				   "<td>" + obj.twork             + "</td>" +
				   "<td>" + obj.teb               + "</td>" +
				   "<td>" + obj.quantityUsed      + "</td>" +
				   "<td>" + obj.usagePerDay       + "</td>" +
				   "<td>" + obj.usagePerYear      + "</td>" +
				   colorizeRes(info.res)                    +
				   "<td>" + info.err + "</td>"              +
				   "</tr>");
	    placeFooter();
	}).error(function( data ) {
	    $( "#results" ).append("<tr><td>" + "ERROR" + "</td></tr>");
	    placeFooter();
	});

    });

});
</script>

<label for="protective-devices">
  <!-- TMPL_VAR protective-devices-lb -->
</label>
<select id="protective-devices" multiple>
  <!-- TMPL_LOOP option-protective-devices -->
  <option value="<!-- TMPL_VAR protective-device -->">
    <!-- TMPL_VAR protective-device -->
  </option>
  <!-- /TMPL_LOOP  -->
</select>
<label for="physical-states"><!-- TMPL_VAR physical-states-lb --></label>
<select id="physical-states" multiple>
  <!-- TMPL_LOOP option-phys-states -->
  <option value="<!-- TMPL_VAR phys-state -->">
    <!-- TMPL_VAR phys-state -->
  </option>
  <!-- /TMPL_LOOP  -->
</select>
<label for="working-temp"><!-- TMPL_VAR working-temp-lb --></label>
<input type="text" id="working-temp" value="25"/>
<label for="boiling-point"><!-- TMPL_VAR boiling-point-lb --></label>
<input type="text" id="boiling-point" value="100"/>
<label for="quantity-used"><!-- TMPL_VAR quantity-used-lb --></label>
<input type="text" id="quantity-used" value="100"/>
<label for="usage-per-day"><!-- TMPL_VAR usage-per-day-lb --></label>
<input type="text" id="usage-per-day" value="100"/>
<label for="usage-per-year"><!-- TMPL_VAR usage-per-year-lb --></label>
<input type="text" id="usage-per-year" value="100"/xk>
<input id="start" type="submit" value="Calculate" />
<table id="results">
  <tr>
    <th>
      <!-- TMPL_VAR protective-devices-lb -->
    </th>
    <th>
      <!-- TMPL_VAR physical-states-lb -->
    </th>
    <th>
      <!-- TMPL_VAR working-temp-lb -->
    </th>
    <th>
      <!-- TMPL_VAR boiling-point-lb -->
    </th>
    <th>
      <!-- TMPL_VAR quantity-used-lb -->
    </th>
    <th>
      <!-- TMPL_VAR usage-per-day-lb -->
    </th>
    <th>
      <!-- TMPL_VAR usage-per-year-lb -->
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
