<script src="<!-- TMPL_VAR path-prefix -->/js/table2csv.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/sum-column.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/delete-row-dynamic.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/clear-all-forms.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/autocomplete-chemicals.js"></script>

<script>

 $(function() {
     $( "#start" ).click(function(e){
	 function colorizeRes (val){
	     var bgColor ="#ff0000";

             if (val < 0.0){
		 bgColor = "#ff00ff";
	     } else if (val < 1){
		 bgColor = "#00ff00";
	     }

	     return bgColor;
	 }

	 var extractText = function (a) { return $(a).text().trim(); }

         function sumMsgFn (s) {
             return "<span style=\"background-color:" + colorizeRes(s) + '">' + s + "</span>";
         }


         $( "#sum-selected" ).click(sumGenFunction(sumMsgFn));

         $( "#dialog-sum" ).dialog({
             show:  { effect: false },
             autoOpen: false
         });

	 function extractSelected (a) {
	     return $.makeArray($(a).children( "option:selected" )).map(extractText);
	 }

	 var obj                = {};
         obj.labName            = $( "#lab-name" ).val().trim();
	 obj.name               = $( "#chem-name" ).val().trim();
	 obj.protectiveDevice   = extractSelected($( "#protective-devices" ));
	 obj.physicalState      = extractSelected($( "#physical-states" ));
         obj.twork              = $( "#working-temp" ).val().trim();
         obj.teb                = $( "#boiling-point" ).val().trim();
	 obj.quantityUsed       = $( "#quantity-used"  ).val().trim();
	 obj.usagePerDay        = $( "#usage-per-day"  ).val().trim();
	 obj.usagePerYear       = $( "#usage-per-year" ).val().trim();
         obj.notes              = $( "#notes" ).val().trim();
	 var jj = JSON.stringify(obj);
	 $.ajax({
	     url:    "<!-- TMPL_VAR service-link -->",
	     method: "POST",
	     data: { req: jj }
	 }).success(function( data ) {
	     var info = JSON.parse(data);
	     var tplView = {};
	     var tpl     = "<tr>"                                                               +
                           "<td>{{labName}}</td>"                                               +
			   "<td>{{name}}</td>"                                                  +
			   "<td>{{protectiveDevice}}</td>"                                      +
			   "<td>{{physicalState}}</td>"                                         +
			   "<td>{{twork}}</td>"                                                 +
			   "<td>{{teb}}</td>"                                                   +
			   "<td>{{quantityUsed}}</td>"                                          +
			   "<td>{{usagePerDay}}</td>"                                           +
			   "<td>{{usagePerYear}}</td>"                                          +
			   "<td class=  \"sum\" style=\"background: {{bgRes}}\">{{res}}</td>"   +
                           "<td >{{notes}}</td>"                                                  +
			   "<td >{{err}}</td>"                                                  +
			   "<td>"                                                               +
			   "<i class=\"fa fa-remove fa-2x table-button delete-row-button\""     +
                           " aria-hidden=\"true\">"                                             +
			   "</i>"                                                               +
                           "</td>"                                                              +
			   "</tr>";
             tplView.labName          = obj.labName;
	     tplView.name             = obj.name;
	     tplView.protectiveDevice = obj.protectiveDevice;
	     tplView.physicalState    = obj.physicalState;
	     tplView.twork            = obj.twork;
	     tplView.teb              = obj.teb;
	     tplView.quantityUsed     = obj.quantityUsed;
	     tplView.usagePerDay      = obj.usagePerDay;
	     tplView.usagePerYear     = obj.usagePerYear;
             tplView.notes            = obj.notes;
	     tplView.bgRes            = colorizeRes(info.res);
	     tplView.res              = info.res;
	     tplView.err              = info.err;

	     $( "#results" ).append(Mustache.render(tpl, tplView));
	     placeFooter();
	 }).error(function( data ) {
	     $( "#results" ).append("<tr><td>" + "ERROR" + "</td></tr>");
	     placeFooter();
	 });

     });

     $("#export-csv-button").click(function (e){
	 let csv = table2csv("results");
	 location.href = "data:text/csv;base64," +  window.btoa(csv);
     });

     var availableChemicals   = <!-- TMPL_VAR json-chemicals -->;
     var availableChemicalsId = <!-- TMPL_VAR json-chemicals-id -->;

     buildAutocompleteChemicals("#chem-name", "#chem-id",
				availableChemicals, availableChemicalsId);

     $("#clear-forms").on('click', clearAllForms);
 });
</script>

<form onclick="return false;">
    <div id="dialog-sum" title="Total"></div>

    <label for="lab-name"><!-- TMPL_VAR lab-name-lb --></label>
    <input type="text" id="lab-name" value=""/>

    <label for="chem-name"
           class="input-autocomplete-label">
        <!-- TMPL_VAR chem-name-lb -->
    </label>
    <input id="chem-id" type="hidden" name="" />
    <span class="ui-widget">
	<input type="text" id="chem-name" value=""/>
    </span>

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
    <input type="text" id="working-temp" value="20"/>
    <label for="boiling-point"><!-- TMPL_VAR boiling-point-lb --></label>
    <input type="text" id="boiling-point" value="100"/>
    <label for="quantity-used"><!-- TMPL_VAR quantity-used-lb --></label>
    <input type="text" id="quantity-used" value="100"/>
    <label for="usage-per-day"><!-- TMPL_VAR usage-per-day-lb --></label>
    <input type="text" id="usage-per-day" value="100"/>
    <label for="usage-per-year"><!-- TMPL_VAR usage-per-year-lb --></label>
    <input type="text" id="usage-per-year" value="100"/>

    <label for="notes"><!-- TMPL_VAR  notes-lb --></label>
    <textarea id ="notes"
              cols="70"
              rows="10"
	      name="notes"></textarea>

    <input id="start" type="submit" value="Calculate" />


    <h3>
	<!-- TMPL_VAR table-res-header -->
	<a id="export-csv-button" class="help-button">
	    <!-- TMPL_INCLUDE 'download-button.tpl' -->
	</a>
    </h3>

    <input id="sum-selected" type="submit"
	   name=""
	   value="<!-- TMPL_VAR sum-quantities-lb -->"/>
    <button id="clear-forms"><!-- TMPL_VAR clear-lb --></button>
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->

<table id="results" class="sortable">
    <tr>
        <th>
	    <!-- TMPL_VAR lab-name-lb -->
	</th>
	<th>
	    <!-- TMPL_VAR chem-name-lb -->
	</th>

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
	    <!-- TMPL_VAR notes-lb -->
	</th>
	<th>
	    <!-- TMPL_VAR errors-lb -->
	</th>
	<th>
	    <!-- TMPL_VAR operations-lb -->
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
