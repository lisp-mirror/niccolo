<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<script>
    // Shorthand for $( document ).ready()
    $(function() {
	var availableCodes = <!-- TMPL_VAR json-prec-code -->;
	var availableId   = <!-- TMPL_VAR json-prec-id -->;
	$( "#target-prec" ).autocomplete({
	    source: availableCodes ,
	    select: function( event, ui ) {
		var idx = $.inArray(ui.item.label, availableCodes);
		$("#target-preccode-id").val(availableId[idx]);
	    }
	});
    });
</script>

<div class="compound-name"><!-- TMPL_VAR compound-name --></div>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/add-assoc-chem-prec/">
  <label for="target-prec"><!-- TMPL_VAR name-lb --></label>
  <input id="target-compound-id" type="hidden" name="<!-- TMPL_VAR prec-compound-id -->"
	 value="<!-- TMPL_VAR value-prec-compound-id -->"/>
  <input id="target-preccode-id" type="hidden" name="<!-- TMPL_VAR prec-code-id -->" />
  <span class="ui-widget">
    <input type="text" id="target-prec"/>
  </span>
  <input type="submit" />
</form>

<table class="sortable preccode-list">
  <thead>
    <tr>
      <th class="prec-id-hd">ID</th>
      <th class="prec-desc-hd"><!-- TMPL_VAR description-lb --></th>
      <th class="prec-op-hd"><!-- TMPL_VAR operations-lb --></th>
    </tr>
  </thead>
  <tbody>
  <!-- TMPL_LOOP data-table -->
  <tr>
    <td class="prec-desc">
      <!-- TMPL_VAR id -->
    </td>

    <td class="prec-desc">
      <!-- TMPL_VAR desc -->
    </td>
    <td class="prec-delete-link">
      <a href="<!-- TMPL_VAR delete-link -->">
	<div class="delete-button">
	  &nbsp;
	</div>
      </a>
    </td>
  </tr>
  <!-- /TMPL_LOOP  -->
  </tbody>
</table>
