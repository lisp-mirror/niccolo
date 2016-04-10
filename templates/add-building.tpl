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
  <label for="name-text">Name</label>
  <input id="name-text" type="text" name="<!-- TMPL_VAR name -->" />
  <label for="target-address">Address</label>
  <input id="target-address-id" type="hidden" name="<!-- TMPL_VAR address-id -->" />
  <span class="ui-widget">
    <input type="text" id="target-address"/>
  </span>

  <input type="submit" />
</form>


<table class="sortable building-list">
  <thead>
    <tr>
      <th class="build-name-hd">Name</th>
      <th class="build-address-hd">Address</th>
      <th class="build-address-link-hd">Link</th>
      <th class="build-operations">Operations</th>
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
      <div class="link-button">
	<a href="<!-- TMPL_VAR link -->">
	  &nbsp;
	</a>
      </div>
    </td>
    <td class="build-delete-link">
      <a href="<!-- TMPL_VAR delete-link -->">
	<div class="delete-button">
	  &nbsp;
	</div>
      </a>
      <a href="<!-- TMPL_VAR update-link -->">
	<div class="edit-button">&nbsp;</div>
      </a>
    </td>
  </tr>
  <!-- /TMPL_LOOP  -->
  </tbody>
</table>
