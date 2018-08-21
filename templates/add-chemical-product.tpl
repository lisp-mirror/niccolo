<script src="<!-- TMPL_VAR path-prefix -->/js/place-footer.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/misc.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/dialog-building.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/dialog-GHS-haz.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/dialog-GHS-prec.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/sum-product-quantity-dialog.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/get-get.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/federated-query.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/table2csv.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/autocomplete-chemicals.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/decode-html-entities.js"></script>

<script>
 // Shorthand for $( document ).ready()
 $(function() {

     $( "#validity-date" ).datepicker({dateFormat : "yy-mm-dd"});

     $( "#expire-date" ).datepicker({dateFormat : "yy-mm-dd"});

     var availableStorages = <!-- TMPL_VAR json-storages -->.map(decodeHtmlEntities);
     var availableStoragesId   = <!-- TMPL_VAR json-storages-id -->;
     $( "#target-storage" ).autocomplete({
	 source: availableStorages ,
	 select: function( event, ui ) {
	     var idx = $.inArray(ui.item.label, availableStorages);
	     $("#target-storage-id").val(availableStoragesId[idx]);
	 }
     });

     var availableChemicals = <!-- TMPL_VAR json-chemicals -->;
     var availableChemicalsId   = <!-- TMPL_VAR json-chemicals-id -->;

     buildAutocompleteChemicals("#target-chemical", "#target-chemical-id",
				availableChemicals, availableChemicalsId);

     $( "#target-chemical-shortage" ).autocomplete({
	 source: availableChemicals ,
	 select: function( event, ui ) {
	     var idx = $.inArray(ui.item.label, availableChemicals);
	     $("#target-chemical-shortage-id").val(availableChemicalsId[idx]);
	 }
     });

     // let's try to align button
     var addPos= $( "#submit-add" ).position();
     $( "#submit-search").css("position", "absolute");
     $( "#submit-search").css("top", addPos.top);
     $( ".search-chem-prod").height(addPos.top);
     $( ".add-new-chem-prod").height(addPos.top);
     $( ".other-ops-chem-prod").height(addPos.top);

     placeFooter();
     $( "#select-all").click(function (e){
	 e.preventDefault();
	 $( "input[type=checkbox]").prop("checked", true);
     });

     $( "#deselect-all").click(function (e){
	 e.preventDefault();
	 $( "input[type=checkbox]").prop("checked", false);
     });

     $( "#dialog-chem-cid" ).dialog({
	 show:  { effect: false },
	 title: "Information",
	 autoOpen: false
     });

     function cleanField (field){
	 return field.replace(/\[[^\]]+\]/g, "").replace(/[\s]{2,}/g, "");

     }

     $("#export-csv-local-button").click(function (e){
	 let csv = table2csv("local-results", cleanField);
	 console.log(csv);
	 location.href = "data:text/csv;base64," +  window.btoa(csv);
     });

     if (mobilep()){  // this is a mobile device
	 $("fieldset").remove();
	 $(".logout-link").css("float", "none")
                          .css("font-size","200%");
	 $(".left-menu").remove();
	 $("th,td").not("*[class^='chemp-name'],*[class^='chemp-shelf']").remove();
         $(".section-title").css("font-size", "6pt");
	 $("#main-wrapper").css("display", "block");
	 $("#main-wrapper").css("width", "100%");
	 $("#main-content-wrapper").css("display", "block");
	 $("#main-content-wrapper").css("width", "100%");

	 $("table").css("width", "100%");

     } // end if (mobilep)

     function verifyRegistryNumbers(numberString, checkDigit){
	 var arrDgt = numberString.split('');
	 var sum    = arrDgt.reduce(function(a, b){ return parseInt(a) + parseInt(b);}, 0);
	 var div    = sum / 10.0;
	 return  ((div - parseInt(div)) * 10) == parseInt(checkDigit);
     }

     // federated-query

     if(getParameterByName('<!-- TMPL_VAR name -->') != null &&
	getParameterByName('<!-- TMPL_VAR name -->') != ""   &&
	!mobilep()){
	 let key        = getParameterByName('<!-- TMPL_VAR name -->'),
	     urlKey     = "<!-- TMPL_VAR fq-query-key-param -->",
	     startUrl   = "<!-- TMPL_VAR fq-start-url -->",
	     resultsUrl = "<!-- TMPL_VAR fq-results-url -->",
	     successFn  = function (data){
		 try{
		     var info = JSON.parse(data);
		     info.forEach(function (a) {
			 let tplView = {},
                             tpl     = "<tr>"            +
				       "<td>{{host}}</td>"         +
				       "<td>{{chempId}}</td>"      +
				       "<td>{{ownerName}}</td>"    +
				       "<td>{{chemName}}</td>"     +
				       "<td>{{buildingName}}</td>" +
				       "<td>{{storageFloor}}</td>" +
				       "<td>{{storageName}}</td>"  +
				       "<td>{{shelf}}</td>"        +
				       "<td>{{quantity}}</td>"     +
				       "<td>{{units}}</td>"        +
				       "<td >{{notes}}</td>"       +
				       "</tr>";
			 tplView.host         = a.host;
			 tplView.chempId      = a.chempId;
			 tplView.ownerName    = a.ownerName;
			 tplView.chemName     = a.chemName;
			 tplView.buildingName = a.buildingName;
			 tplView.storageFloor = a.storageFloor;
			 tplView.storageName  = a.storageName;
			 tplView.shelf        = a.shelf;
			 tplView.quantity     = a.quantity;
			 tplView.units        = a.units;
			 tplView.notes        = a.notes;

			 $("#fq-results tbody" ).append(Mustache.render(tpl, tplView));
		     });
		 }catch (a){};
		 placeFooter();

	     },
	     errorFn  = function(a) { placeFooter();};

	 federatedQuery(key, urlKey, startUrl, resultsUrl, successFn, errorFn);
     }else{
	 $( "#fq-res-container" ).empty();
     }

 });
</script>

<div id="dialog-building" title=""></div>

<div id="dialog-GHS-haz" title=""></div>

<div id="dialog-GHS-prec" title=""></div>

<div id="dialog-chem-cid" title=""></div>

<div id="dialog-sum-quantity" title="Total"></div>
<div class="chem-prod-add-searh-wrapper">
    <fieldset class="add-new-chem-prod">
        <legend><!-- TMPL_VAR add-new-product-lb --></legend>
        <form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/add-chem-prod/">
            <label for="target-chemical"
                   class="input-autocomplete-label">
                <!-- TMPL_VAR compound-name-lb -->
            </label>
            <input id="target-chemical-id" type="hidden" name="<!-- TMPL_VAR chemical-id -->" />
            <span class="ui-widget">
                <input type="text" id="target-chemical"/>
            </span>
            <label for="target-storage"
                   class="input-autocomplete-label">
                <!-- TMPL_VAR storage-name-lb -->
            </label>
            <input id="target-storage-id" type="hidden"
                   name="<!-- TMPL_VAR storage-id -->" />
            <span class="ui-widget">
                <input type="text" id="target-storage" />
            </span>

            <label for="shelf"><!-- TMPL_VAR shelf-lb --></label>
            <input id="shelf" type="text" name="<!-- TMPL_VAR shelf -->" />

            <label for="quantity"><!-- TMPL_VAR quantity-lb --></label>
            <input id="quantity" type="text" name="<!-- TMPL_VAR quantity -->" />

            <label for="units"><!-- TMPL_VAR units-lb --></label>
            <input id="units" type="text" name="<!-- TMPL_VAR units -->" />

            <label for="validity-date"><!-- TMPL_VAR validity-date-lb --></label>
            <input id="validity-date" type="text" name="<!-- TMPL_VAR validity-date -->" />

            <label for="expire-date"><!-- TMPL_VAR expire-date-lb --></label>
            <input id="expire-date" type="text" name="<!-- TMPL_VAR expire-date -->" />

            <label for="count"><!-- TMPL_VAR item-count-lb --></label>
            <input id="count" type="text" name="<!-- TMPL_VAR count -->" />

            <label for="textarea-add-chem-prod"><!-- TMPL_VAR  notes-optional-lb --></label>
            <textarea id ="textarea-add-chem-prod" class="textarea-add-chem-prod"
	              name="<!-- TMPL_VAR notes -->"></textarea>

            <input id="submit-add" type="submit" />
        </form>
    </fieldset>

    <fieldset class="search-chem-prod">
        <legend><!-- TMPL_VAR search-products-legend-lb --></legend>
        <form method="POST" ACTION="<!-- TMPL_VAR path-prefix -->/post-search-chem-prod/"
	              enctype="multipart/form-data">
            <label for="chem-owner"><!-- TMPL_VAR barcode-number-lb --></label>
            <input id="chem-id" type="text" name="<!-- TMPL_VAR chemp-id -->">
            <label for="chem-owner"><!-- TMPL_VAR owner-lb --></label>
            <input id="chem-owner" type="text" name="<!-- TMPL_VAR owner -->"
	           value="<!-- TMPL_VAR value-owner -->" />
            <label for="chem-name"><!-- TMPL_VAR name-lb --></label>
            <input id="chem-name" type="text" name="<!-- TMPL_VAR name -->" />
            <label for="chem-building"><!-- TMPL_VAR building-lb --></label>
            <input id="chem-building" type="text" name="<!-- TMPL_VAR building -->" />
            <label for="chem-floor"><!-- TMPL_VAR floor-lb --></label>
            <input id="chem-floor" type="text" name="<!-- TMPL_VAR floor -->" />
            <label for="chem-storage"><!-- TMPL_VAR storage-name-lb --></label>
            <input id="chem-storage" type="text" name="<!-- TMPL_VAR storage -->" />
            <label for="chem-shelf"><!-- TMPL_VAR shelf-lb --></label>
            <input id="chem-shelf" type="text" name="<!-- TMPL_VAR search-shelf -->" />
            <label for="struct-file"><!-- TMPL_VAR struct-file-lb --></label>
            <input id="struct-file" type="file" name="<!-- TMPL_VAR struct-data -->" />
            <input id="submit-search" type="submit" />
        </form>
    </fieldset>
</div>

<form method="POST" ACTION="<!-- TMPL_VAR path-prefix -->/others-op-chem-prod/">
  <fieldset class="other-ops-chem-prod">
    <legend><!-- TMPL_VAR  other-operations-lb --></legend>
    <input id="select-all" type="submit"
	   name=""
	   value="<!-- TMPL_VAR select-all-lb -->"/>
    <input id="deselect-all" type="submit"
	   name=""
	   value="<!-- TMPL_VAR deselect-all-lb -->"/>
    <input id="submit-gen-barcode" type="submit"
	   name="<!-- TMPL_VAR submit-gen-barcode -->"
	   value="<!-- TMPL_VAR submit-gen-barcode-lb -->"/>
    <input id="submit-mass-delete" type="submit"
	   name="<!-- TMPL_VAR submit-massive-delete -->"
	   value="<!-- TMPL_VAR submit-massive-delete-lb -->"/>
    <input id="sum-selected" type="submit"
	   name=""
	   value="<!-- TMPL_VAR sum-quantities-lb -->"/>
    <fieldset class="lending">
      <legend><!-- TMPL_VAR lending-lb --></legend>
      <label for="username-lending"><!-- TMPL_VAR user-lb --></label>
      <input id="username-lending" type="text"
	     name="<!-- TMPL_VAR username-lending -->" />
      <input id="submit-lend-to" type="submit"
	     name="<!-- TMPL_VAR submit-lend-to -->"
	     value="<!-- TMPL_VAR submit-lend-to-lb -->"/>
    </fieldset>

    <fieldset class="chem-shortage">
      <legend><!-- TMPL_VAR  shortage-threshold-lb --></legend>
      <label for="target-chemical-shortage-id"
             class="input-autocomplete-label">
          <!-- TMPL_VAR compound-name-lb -->
      </label>
      <input id="target-chemical-shortage-id" type="hidden" name="<!-- TMPL_VAR chemical-id -->" />
      <span class="ui-widget">
	<input type="text" id="target-chemical-shortage"/>
      </span>
      <label for="shortage-threshold"><!-- TMPL_VAR threshold-lb --></label>
      <input id="count" type="text"
	     value="<!-- TMPL_VAR shortage-threshold-value -->"
	     name="<!-- TMPL_VAR shortage-threshold -->" />
      <input id="submit-chem-shortage" type="submit"
	     name="<!-- TMPL_VAR submit-change-shortage -->"
	     value="<!-- TMPL_VAR submit-shortage-lb -->"/>
    </fieldset>

  </fieldset>


  <!-- TMPL_IF render-local-results-p -->
  <h3>
    <!-- TMPL_VAR table-res-header -->
    <a id="export-csv-local-button" class="help-button">
      <!-- TMPL_INCLUDE 'download-button.tpl' -->
    </a>
  </h3>

  <table class="sortable chemp-list"  id="local-results">
    <thead>
      <tr>
	<th class="chemp-select-id-hd"><!-- TMPL_VAR select-lb --></th>
	<th class="chemp-id-hd">ID</th>
	<th class="chemp-owner-hd"><!-- TMPL_VAR owner-lb --></th>
	<th class="chemp-name-hd"><!-- TMPL_VAR  name-lb --></th>
	<th class="chemp-thumb-hd"><!-- TMPL_VAR  structure-lb --></th>
	<th class="chemp-haz-diamond-hd"><!-- TMPL_VAR  haz-diamond-lb --></th>
	<th class="chemp-building-name-hd"><!-- TMPL_VAR building-lb --></th>
	<th class="chemp-floor-hd"><!-- TMPL_VAR floor-lb --></th>
	<th class="chemp-storage-hd"><!-- TMPL_VAR storage-lb --></th>
	<th class="chemp-shelf-hd"><!-- TMPL_VAR shelf-lb --></th>
	<th class="chemp-quantity-hd"><!-- TMPL_VAR quantity-lb --></th>
	<th class="chemp-quantity-hd"><!-- TMPL_VAR units-lb --></th>
	<th class="chemp-validity-date-hd"><!-- TMPL_VAR validity-date-lb --></th>
	<th class="chemp-expire-date-hd"><!-- TMPL_VAR expire-date-lb --></th>
	<th class="chemp-opening-date-hd"><!-- TMPL_VAR opening-package-date-lb --></th>
	<th class="chemp-shortage-threshold-hd"><!-- TMPL_VAR shortage-threshold-lb --></th>
	<th class="chemp-notes-hd"><!-- TMPL_VAR notes-lb --></th>
	<th class="chemp-operations"><!-- TMPL_VAR operations-lb --></th>
      </tr>
    </thead>
    <tbody>
      <!-- TMPL_LOOP data-table -->
      <tr>
	<td class="select-id-id">
	  <input name="<!-- TMPL_VAR checkbox-id -->" type="checkbox" />
	</td>
	<td class="chemp-id">
	    <!-- TMPL_VAR chemp-id -->
	</td>
	<td class="chemp-owner">
	  <!-- TMPL_VAR owner-name -->
	  <!-- TMPL_IF lending-user -->
	  <sub>
	    <img class="lend-hand" src="<!-- TMPL_VAR path-prefix -->/images/hand.png" width="16" />
	    <span class="parent-subscript">[</span>
	    <!-- TMPL_VAR lending-user -->
	    <span class="parent-subscript">]</span>
	  </sub>
	  <!-- /TMPL_IF -->
	</td>
	<td class="chemp-name">
  	  <!-- TMPL_IF chem-cid-exists -->
	  <script>
    // Shorthand for $( document ).ready()
    $(function() {
	var cid = <!-- TMPL_VAR chem-cid -->;
	var availableStoragesId   = <!-- TMPL_VAR json-storages-id -->;
	var pubchemLink = "https://<!-- TMPL_VAR pubchem-host -->/rest/pug/compound/cid/<!-- TMPL_VAR chem-cid -->/property/MolecularFormula,MolecularWeight,IUPACName,ExactMass,Charge/JSON";
	var pubchemRNSection = 'https://<!-- TMPL_VAR pubchem-host -->/compound/' +
	                       '<!-- TMPL_VAR chem-cid -->'                 +
                               '#section=Names-and-Identifiers';

	$( "#link<!-- TMPL_VAR chemp-id -->-<!-- TMPL_VAR chem-cid -->" ).click(function() {
	    $.getJSON( pubchemLink,
		       function(data) {
			   var info = data.PropertyTable.Properties[0];
			   $( "#dialog-chem-cid" ).children("p").remove();
			   $( "#dialog-chem-cid" ).append("<p>Formula: <b>" + info.MolecularFormula + "</b></p>");
			   $( "#dialog-chem-cid" ).append("<p>Mol. Weight: <b>" + info.MolecularWeight + "</b></p>");
			   $( "#dialog-chem-cid" ).append("<p>IUPAC name: <b>" + info.IUPACName + "</b></p>");
			   $( "#dialog-chem-cid" ).append("<p>Charge:<b>" + info.Charge + "</b></p>");

			   $( "#dialog-chem-cid" ).append('<p><small><a href="' + pubchemRNSection
 + '">More...</a></small></p>');
			   $( "#dialog-chem-cid" ).append('<p><small><i>Data provided by pubchem (<a href="https://www.ncbi.nlm.nih.gov/About/disclaimer.html">disclaimer</a>)</i></small></p>');
			   $( "#dialog-chem-cid" ).dialog("open");
		       });
	});
    });
          </script>

	  <a id="link<!-- TMPL_VAR chemp-id -->-<!-- TMPL_VAR chem-cid -->">
	    <!-- TMPL_VAR chem-name -->
	  </a>
	  <!-- TMPL_ELSE -->
          <!-- TMPL_VAR chem-name -->
	  <!-- /TMPL_IF --><!-- if chem-cid-exists ends here-->
	  <div>
	    <sub>
	      <span class="parent-subscript">[</span>
	      <a class="msds-link" href="<!-- TMPL_VAR msds-link -->">
		MSDS
	      </a>
	      <span class="parent-subscript">]</span>
	    </sub>
	    <sub>
	      <span class="parent-subscript">[</span>
	      <a class="GHS-haz-link" href="<!-- TMPL_VAR ghs-haz-link -->">
		H
	      </a>
	      <span class="parent-subscript">]</span>
	    </sub>
	    <sub>
	      <span class="parent-subscript">[</span>
	      <a class="GHS-prec-link" href="<!-- TMPL_VAR ghs-prec-link -->">
		P
	      </a>
	      <span class="parent-subscript">]</span>
	    </sub>
            <!-- TMPL_IF chemical-tracked-p -->
            <div>
                <sub>
                    <span class="parent-subscript">[</span>
                    <a target="_blank" href="<!-- TMPL_VAR tracking-link -->">
	                <!-- TMPL_INCLUDE 'chart-button.tpl' -->
                    </a>
                    <span class="parent-subscript">]</span>
	        </sub>
            </div>
            <!-- /TMPL_IF -->
	  </div>
	</td>
	<td class="chemp-thumb-name">
	  <a class="struct-large-link" href="<!-- TMPL_VAR structure-link -->"
	     target="_blank">
	    <img class="thumb" src="<!-- TMPL_VAR thumbnail-link -->">
	  </a>
	</td>
	<td class="chemp-haz-diamond">
	  <img src="<!-- TMPL_VAR haz-diamond-url -->" />
	</td>

	<td class="chemp-building-name">
	  <a class="building-link" href="<!-- TMPL_VAR building-link -->">
	    <!-- TMPL_VAR building-name -->
	  </a>
	</td>
	<td class="chemp-floor">
	  <!-- TMPL_VAR storage-floor -->
	</td>
	<td class="chemp-storage">
	  <!-- TMPL_IF storage-link -->
	  <a href="<!-- TMPL_VAR storage-link -->" target="_blank" >
	    <!-- TMPL_VAR storage-name -->
	  </a>
	  <!-- TMPL_ELSE -->
	  <!-- TMPL_VAR storage-name -->
	  <!-- /TMPL_IF -->
	</td>
	<td class="chemp-shelf">
	  <!-- TMPL_VAR shelf -->
	</td>
	<td class="chemp-qty">
	  <!-- TMPL_VAR quantity -->
	</td>
	<td class="chemp-units">
	  <!-- TMPL_VAR units -->
	</td>
	<td class="validity-date">
	  <!-- TMPL_VAR validity-date-decoded -->
	</td>
	<td class="expire-date">
	  <!-- TMPL_VAR expire-date-decoded -->
	</td>
	<td class="opening-date">
	  <!-- TMPL_VAR opening-package-date-decoded -->
	</td>
	<td class="shortage-threshold">
	  <!-- TMPL_VAR shortage-threshold -->
	</td>
	<td class="chemp-notes">
	  <!-- TMPL_VAR notes -->
	</td>
	<td class="operations">
	  <a href="<!-- TMPL_VAR delete-link -->">
	    <!-- TMPL_INCLUDE 'delete-button.tpl' -->
	  </a>
	  <!-- TMPL_IF lending-user -->
	  <a href="<!-- TMPL_VAR remove-lending-link -->">
	    <div class="remove-lending-button">
	      &nbsp;
	    </div>
	  </a>
	  <!-- /TMPL_IF -->
	  <a href="<!-- TMPL_VAR gen-custom-label-link -->">
	      <!-- TMPL_INCLUDE 'tags-button.tpl' -->
	  </a>
	  <!-- edit chemical-product -->
	  <a href="<!-- TMPL_VAR update-link -->">
	      <!-- TMPL_INCLUDE 'edit-button.tpl' -->
	  </a>
	  <a href="<!-- TMPL_VAR barcode-link -->">
	      <!-- TMPL_INCLUDE 'barcode-button.tpl' -->
	  </a>
          <!-- TMPL_UNLESS chemical-tracked-p -->
          <a href="<!-- TMPL_VAR add-tracking-link -->">
	      <!-- TMPL_INCLUDE 'add-chart-button.tpl' -->
          </a>
          <!-- /TMPL_UNLESS -->
          <!-- TMPL_IF chemical-tracked-p -->
          <a href="<!-- TMPL_VAR remove-tracking-link -->">
	      <!-- TMPL_INCLUDE 'remove-chart-button.tpl' -->
          </a>
          <!-- /TMPL_IF -->
	</td>
      </tr>
      <!-- /TMPL_LOOP  -->
    </tbody>
  </table>
  <!-- /TMPL_IF  --> <!-- if render-local-results-p ends here-->

  <!-- federated query results -->
  <div id="fq-res-container">
    <h3>
      <i class="fa fa-cloud-download fa-2x fq-download" aria-hidden="true"></i>
      <!-- TMPL_VAR fq-table-res-header -->
    </h3>

    <table class="sortable chemp-list" id="fq-results">
      <thead>
	<tr>
	  <th class="chemp-select-id-hd"><!-- TMPL_VAR origin-lb --></th>
	  <th class="chemp-id-hd">ID</th>
	  <th class="chemp-owner-hd"><!-- TMPL_VAR owner-lb --></th>
	  <th class="chemp-name-hd"><!-- TMPL_VAR  name-lb --></th>
	  <th class="chemp-building-name-hd"><!-- TMPL_VAR building-lb --></th>
	  <th class="chemp-floor-hd"><!-- TMPL_VAR floor-lb --></th>
	  <th class="chemp-storage-hd"><!-- TMPL_VAR storage-lb --></th>
	  <th class="chemp-shelf-hd"><!-- TMPL_VAR shelf-lb --></th>
	  <th class="chemp-quantity-hd"><!-- TMPL_VAR quantity-lb --></th>
	  <th class="chemp-quantity-hd"><!-- TMPL_VAR units-lb --></th>
	  <th class="chemp-notes-hd"><!-- TMPL_VAR notes-lb --></th>
	</tr>
      </thead>
      <tbody>
      </tbody>
    </table>

    <div class="ajax-loader-federated-query">
      <img src="<!-- TMPL_VAR path-prefix -->/images/ajax-loader.gif" />
    </div>

  </div>

</form>
