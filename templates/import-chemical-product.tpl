<script src="<!-- TMPL_VAR path-prefix -->/js/place-footer.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/misc.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<script>
    // Shorthand for $( document ).ready()
    $(function() {
	var availableBuilding = <!-- TMPL_VAR json-buildings -->;
	var availableId   = <!-- TMPL_VAR json-buildings-id -->;

	$( "#target-building" ).autocomplete({
	    source: availableBuilding ,
	    select: function( event, ui ) {
		var idx = $.inArray(ui.item.label, availableBuilding);
		$("#target-building-id").val(availableId[idx]);
	    }
	});

	$( "#dialog" ).dialog({
	    show:  { effect: false },
	    title: "Information",
	    autoOpen: false,
	    width:'auto'
	});

	$( "#open-help-dialog" ).click(function(e){
	    $( "#dialog" ).dialog("open");
	});

    });

</script>


<fieldset class="import-data">
    <legend><!-- TMPL_VAR import-data-legend-lb -->
	<a id="open-help-dialog" class="help-button">
	  <!-- TMPL_INCLUDE 'question-button.tpl' -->
	</a>
    </legend>
  <form method="POST" ACTION="<!-- TMPL_VAR path-prefix -->/import-chem-prod/"
	enctype="multipart/form-data">
      <label for="target-building"
             class="input-autocomplete-label">
          <!-- TMPL_VAR building-lb -->
      </label>
      <input id="target-building-id" type="hidden" name="<!-- TMPL_VAR building-id -->" />
      <span class="ui-widget">
	  <input type="text" id="target-building"/>
      </span>
      <label for="spreadsheet-file"><!-- TMPL_VAR spreadsheet-file-lb --></label>
      <input id="spreadsheet-file" type="file" name="<!-- TMPL_VAR spreadsheet-data -->" />
      <input id="submit-search" type="submit" />
  </form>
</fieldset>

<div id="dialog" title="">
    <!-- TMPL_VAR help-dialog-lb -->
</div>


<!-- TMPL_IF data-table -->
<table class="sortable chemp-list">
    <thead>
	<tr>
	    <th class="chemp-id-hd">ID</th>
	    <th class="chemp-name-hd"><!-- TMPL_VAR  name-lb --></th>
	    <th class="chemp-building-name-hd"><!-- TMPL_VAR building-lb --></th>
	    <th class="chemp-floor-hd"><!-- TMPL_VAR floor-lb --></th>
	    <th class="chemp-storage-hd"><!-- TMPL_VAR storage-lb --></th>
	    <th class="chemp-shelf-hd"><!-- TMPL_VAR shelf-lb --></th>
	    <th class="chemp-quantity-hd"><!-- TMPL_VAR quantity-lb --></th>
	    <th class="chemp-quantity-hd"><!-- TMPL_VAR units-lb --></th>
	    <th class="chemp-validity-date-hd"><!-- TMPL_VAR validity-date-lb --></th>
	    <th class="chemp-expire-date-hd"><!-- TMPL_VAR expire-date-lb --></th>
	    <th class="chemp-operations"><!-- TMPL_VAR operations-lb --></th>
	</tr>
    </thead>
    <tbody>
	<!-- TMPL_LOOP data-table -->
	<tr>
	    <td class="chemp-id">
		<!-- TMPL_VAR chemp-id -->
	    </td>
	    <td class="chemp-name">
		<!-- TMPL_VAR chem-name -->
	    </td>
	    <td class="chemp-building-name">
		<!-- TMPL_VAR building-name -->
	    </td>
	    <td class="chemp-floor">
		<!-- TMPL_VAR storage-floor -->
	    </td>
	    <td class="chemp-storage">
		<!-- TMPL_VAR storage-name -->
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
	    <td class="operations">
		<!-- edit chemical-product -->
		<a href="<!-- TMPL_VAR update-link -->">
		  <!-- TMPL_INCLUDE 'edit-button.tpl' -->
		</a>
	    </td>
	</tr>
	<!-- /TMPL_LOOP  -->
    </tbody>
</table>
<!-- /TMPL_IF  --> <!-- if data-table ends here-->
