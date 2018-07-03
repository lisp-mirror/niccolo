<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<script>
    // Shorthand for $( document ).ready()
    $(function() {
	var availableAddr = <!-- TMPL_VAR json-addresses -->;
	var availableId   = <!-- TMPL_VAR json-addresses-id -->;
	$( "#target-address" ).autocomplete({
	    source: availableAddr ,
	    select: function( event, ui ) {
		var idx = $.inArray(ui.item.label, availableAddr);
		$("#target-address-id").val(availableId[idx]);
	    }
	});
    });
</script>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/add-building/">
  <label for="name-text"><!-- TMPL_VAR name-lb --></label>
  <input id="name-text" type="text" name="<!-- TMPL_VAR name -->" />
  <label for="target-address"
         class="input-autocomplete-label">
      <!-- TMPL_VAR address-lb -->
  </label>
  <input id="target-address-id" type="hidden" name="<!-- TMPL_VAR address-id -->" />
  <span class="ui-widget">
    <input type="text" id="target-address"/>
  </span>

  <input type="submit" />
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->

<table class="sortable building-list">
  <thead>
    <tr>
      <th class="build-name-hd"><!-- TMPL_VAR name-lb --></th>
      <th class="build-address-hd"><!-- TMPL_VAR address-lb --></th>
      <th class="build-address-link-hd"><!-- TMPL_VAR link-lb --></th>
      <th class="build-operations"><!-- TMPL_VAR operations-lb --></th>
    </tr>
  </thead>
  <tbody>
  <!-- TMPL_LOOP data-table -->
  <tr>
    <td class="build-name">
      <!-- TMPL_VAR name -->
    </td>
    <td class="build-address">
      <!-- TMPL_VAR address -->
    </td>
    <td class="build-link">
      <a href="<!-- TMPL_VAR link -->">
	<!-- TMPL_INCLUDE 'ext-link-button.tpl' -->
      </a>
    </td>
    <td class="build-delete-link">
      <a href="<!-- TMPL_VAR delete-link -->">
	<!-- TMPL_INCLUDE 'delete-button.tpl' -->
      </a>
      <a href="<!-- TMPL_VAR update-link -->">
	<!-- TMPL_INCLUDE 'edit-button.tpl' -->
      </a>
    </td>
  </tr>
  <!-- /TMPL_LOOP  -->
  </tbody>
</table>
