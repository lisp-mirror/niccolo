<script src="<!-- TMPL_VAR path-prefix -->/js/place-footer.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/table2csv.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/sum-column.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/delete-row-dynamic.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/clear-all-forms.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/autocomplete-chemicals.js"></script>

<script>
 // Shorthand for $( document ).ready()
 $(function() {
     function colorizeRes (val){
	 var bgColor ="#ffffff";

         if (val < 0.0){
	     bgColor = "#ff00ff";
	 } else if (val >= 0.001 &&
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

     function sumMsgFn (s) {
         return "<span style=\"background-color:" + colorizeRes(s) + '">' + s + "</span>";
     }

     $( "#sum-selected" ).click(sumGenFunction(sumMsgFn));

     $( "#dialog-sum" ).dialog({
         show:  { effect: false },
         autoOpen: false
     });

     $( "#start" ).on('click', function(e){
	 var extractText = function (a) { return $(a).text().trim(); }

	 function extractSelected (a) {
	     return $.makeArray($(a).children( "option:selected" )).map(extractText);
	 }

	 var obj                = {};
         obj.labName            = $( "#lab-name" ).val().trim();
	 obj.name               = $( "#chem-name" ).val().trim();
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
	 obj.safetyThresholds   = $( "#safety-thresholds" ).val().trim();
         obj.notes              = $( "#notes" ).val().trim();
	 var jj = JSON.stringify(obj);
	 $.ajax({
	     url:    "<!-- TMPL_VAR service-link -->",
	     method: "POST",
	     data: { req: jj }
	 }).success(function( data ) {
	     let info = JSON.parse(data),
		 tplView = {},
		 tpl     = "<tr>"                                                               +
                           "<td>{{labName}}</td>"                                               +
			   "<td>{{name}}</td>"                                                  +
			   "<td>{{rPhrases}}</td>"                                              +
			   "<td>{{expositionTypes}}</td>"                                       +
			   "<td>{{physicalState}}</td>"                                         +
			   "<td>{{workingTemp}}</td>"                                           +
			   "<td>{{boilingPoint}}</td>"                                          +
			   "<td>{{expositionTimeType}}</td>"                                    +
			   "<td>{{expositionTime}}</td>"                                        +
			   "<td>{{usage}}</td>"                                                 +
			   "<td>{{quantityUsed}}</td>"                                          +
			   "<td>{{quantityStocked}}</td>"                                       +
			   "<td>{{workType}}</td>"                                              +
			   "<td>{{protectionsFactor}}</td>"                                     +
			   "<td><pre>{{safetyThresholds}}</pre></td>"                           +
			   "<td class=  \"sum\" style=\"background: {{bgRes}}\">{{res}}</td>"   +
                           "<td >{{notes}}</td>"                                                +
			   "<td >{{err}}</td>"                                                  +
			   "<td>"                                                               +
			   "<i class=\"fa fa-remove fa-2x table-button delete-row-button\""     +
                           " aria-hidden=\"true\">"                                             +
			   "</i>"                                                               +
                           "</td>"                                                              +
			   "</tr>";
             tplView.labName            = obj.labName;
	     tplView.name               = obj.name;
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
	     tplView.safetyThresholds   = obj.safetyThresholds;
	     tplView.bgRes              = colorizeRes(info.res);
             tplView.notes              = obj.notes;
	     tplView.res                = info.res;
	     tplView.err                = info.err;
	     $( "#results" ).append(Mustache.render(tpl,tplView));
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
    <input type="text" id="working-temp" value="20"/>

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

    <label for="quantity-stocked"><!-- TMPL_VAR quantity-stocked-minimum-lb --></label>
    <select id="quantity-stocked">
	<!-- TMPL_LOOP option-quantity-stocked -->
	<option value="<!-- TMPL_VAR quantity-stocked  -->"><!-- TMPL_VAR quantity-stocked  --></option>
	<!-- /TMPL_LOOP  -->
    </select>


    <label for="work-type"><!-- TMPL_VAR work-type-lb --></label>
    <select id="work-type">
	<!-- TMPL_LOOP option-work-types -->
	<option value="<!-- TMPL_VAR work-type -->"><!-- TMPL_VAR work-type --></option>
	<!-- /TMPL_LOOP  -->
    </select>

    <label for="protection-factors"><!-- TMPL_VAR collective-protection-factors-lb --></label>
    <select id="protection-factors" multiple>
	<!-- TMPL_LOOP option-protection-factors -->
	<option value="<!-- TMPL_VAR protection-factor -->"><!-- TMPL_VAR protection-factor -->
	</option>
	<!-- /TMPL_LOOP  -->
    </select>

    <label for="safety-thresholds"><!-- TMPL_VAR  safety-thresholds-lb --></label>
    <textarea id ="safety-thresholds"
              cols="150"
              rows="20"
	      name="safety-thresholds"></textarea>


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

    <button id="clear-forms">
	<!-- TMPL_VAR clear-lb -->
    </button>
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
	    <!-- TMPL_VAR quantity-stocked-minimum-table-h-lb -->
	</th>
	<th>
	    <!-- TMPL_VAR work-type-lb -->
	</th>
	<th>
	    <!-- TMPL_VAR collective-protection-factors-lb -->
	</th>
	<th>
	    <!-- TMPL_VAR safety-threshold-lb -->
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
	ISPRA - Istituto Superiore per la Protezione e la Ricerca Ambientale
    </div>
    <div class="title">
	Manuale per la Valutazione del Rischio da Esposizione ad
        Agenti Chimici Pericolosi e ad Agenti Cancerogeni e Mutageni
    </div>
    <div class="publication">
	Manuali e Linee Guida 164/2017
    </div>
    <div class="biblio-id">
	ISBN: 978-88-448-0850-1
    </div>
</div>
