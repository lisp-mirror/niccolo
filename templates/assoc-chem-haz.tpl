<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<script>
    // Shorthand for $( document ).ready()
    $(function() {
	var availableCodes = <!-- TMPL_VAR json-haz-code -->;
	var availableId   = <!-- TMPL_VAR json-haz-id -->;
	$( "#target-haz" ).autocomplete({
	    source: availableCodes ,
	    select: function( event, ui ) {
		var idx = $.inArray(ui.item.label, availableCodes);
		$("#target-hazcode-id").val(availableId[idx]);
	    }
	});
    });
</script>

<div class="compound-name"><!-- TMPL_VAR compound-name --></div>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/add-assoc-chem-haz/">
  <label for="target-haz"><!-- TMPL_VAR name-lb --></label>
  <input id="target-compound-id" type="hidden" name="<!-- TMPL_VAR haz-compound-id -->"
	 value="<!-- TMPL_VAR value-haz-compound-id -->"/>
  <input id="target-hazcode-id" type="hidden" name="<!-- TMPL_VAR haz-code-id -->" />
  <span class="ui-widget">
    <input type="text" id="target-haz"/>
  </span>
  <input type="submit" />
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->

<table class="sortable hazcode-list">
  <thead>
    <tr>
      <th class="haz-id-hd">ID</th>
      <th class="haz-desc-hd"><!-- TMPL_VAR description-lb --></th>
      <th class="haz-op-hd"><!-- TMPL_VAR operations-lb --></th>
    </tr>
  </thead>
  <tbody>
  <!-- TMPL_LOOP data-table -->
  <tr>
    <td class="haz-desc">
      <!-- TMPL_VAR id -->
    </td>

    <td class="haz-desc">
      <!-- TMPL_VAR desc -->
    </td>
    <td class="haz-delete-link">
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
