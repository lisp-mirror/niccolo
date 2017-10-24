<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/misc.js"></script>

<script>
    // Shorthand for $( document ).ready()
    $(function () {
	var reError = new RegExp("error");
	$('td').each(function( index ) {
	    if(reError.test($( this ).text())){
		$( this ).addClass("ui-state-error");
	    }
	});
    })
</script>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/add-sensor/">
  <label for="description-text"><!-- TMPL_VAR description-lb --></label>
  <input id="description-text" type="text" name="<!-- TMPL_VAR description -->" />
  <label for="address-text"><!-- TMPL_VAR address-lb --></label>
  <input id="address-text" type="text" name="<!-- TMPL_VAR address -->" />
  <label for="path-text"><!-- TMPL_VAR path-lb --></label>
  <input id="path-text" type="text" name="<!-- TMPL_VAR path -->" />
  <label for="secret-text"><!-- TMPL_VAR secret-lb --></label>
  <input id="secret-text" type="password" name="<!-- TMPL_VAR secret -->" />
  <label for="script-text"><!-- TMPL_VAR script-lb --></label>
  <input id="script-text" type="text" name="<!-- TMPL_VAR script -->" />
  <input type="submit" />
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->

<table class="sortable storage-list">
  <thead>
    <tr>
      <th class="sensor-id-hd">ID</th>
      <th class="sensor-map-link-hd"><!-- TMPL_VAR map-lb --></th>
      <th class="sensor-description-hd"><!-- TMPL_VAR description-lb --></th>
      <th class="sensor-address-hd"><!-- TMPL_VAR address-lb --></th>
      <th class="sensor-path-hd"><!-- TMPL_VAR path-lb --></th>
      <th class="sensor-script-hd"><!-- TMPL_VAR script-lb --></th>
      <th class="sensor-status-hd"><!-- TMPL_VAR status-lb --></th>
      <th class="sensor-last-value-hd"><!-- TMPL_VAR last-value-lb --></th>
      <th class="sensor-last-value-hd"><!-- TMPL_VAR last-access-time-lb --></th>
      <th class="sensor-operations"><!-- TMPL_VAR operations-lb --></th>
    </tr>
  </thead>
  <tbody>
  <!-- TMPL_LOOP data-table -->
  <tr>
    <td class="sensor-id">
      <!-- TMPL_VAR sensor-id -->
    </td>
    <td class="sensor-link">
      <!-- TMPL_IF has-sensor-link -->
      <a href="<!-- TMPL_VAR sensor-link -->" target="_blank" >
	<!-- TMPL_INCLUDE 'map-marker-button.tpl' -->
      </a>
      <!-- /TMPL_IF -->
    </td>
    <td class="sensor-description">
      <!-- TMPL_VAR description -->
    </td>
    <td class="sensor-address">
	<!-- TMPL_VAR address -->
    </td>
    <td class="sensor-path">
      <!-- TMPL_VAR path -->
    </td>
    <td class="sensor-script">
      <!-- TMPL_VAR script -->
    </td>
    <td class="sensor-status">
      <!-- TMPL_VAR status -->
    </td>
    <td class="sensor-last-value">
      <!-- TMPL_VAR last-value -->
    </td>
    <td class="sensor-last-access-time">
      <!-- TMPL_VAR last-access-time -->
    </td>

    <td class="sensor-delete-link">
      <a href="<!-- TMPL_VAR delete-link -->">
	<!-- TMPL_INCLUDE 'delete-button.tpl' -->
      </a>
      <a href="<!-- TMPL_VAR location-add-link -->">
	<!-- TMPL_INCLUDE 'add-map-button.tpl' -->
      </a>
      <a href="<!-- TMPL_VAR update-sensor-link -->">
	<!-- TMPL_INCLUDE 'edit-button.tpl' -->
      </a>
      <!-- TMPL_IF has-sensor-log -->
      <a target="_blank" href="<!-- TMPL_VAR graph-sensor-link -->">
	<!-- TMPL_INCLUDE 'chart-button.tpl' -->
      </a>
      <!-- /TMPL_IF -->
    </td>
  </tr>
  <!-- /TMPL_LOOP  -->
  </tbody>
</table>

<!-- TMPL_INCLUDE 'pagination-navigation.tpl' -->
