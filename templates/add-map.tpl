<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<form method="POST" ACTION="<!-- TMPL_VAR path-prefix -->/add-map/" enctype="multipart/form-data">
  <label for="desc-text"><!-- TMPL_VAR description-lb --></label>
  <input id="desc-text" type="text" name="<!-- TMPL_VAR desc -->" />
  <label for="map-file"><!-- TMPL_VAR map-file-png-lb --></label>
  <input id="map-file" type="file" name="<!-- TMPL_VAR data -->" />
  <input type="submit" />
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->

<table class="sortable map-list">
  <thead>
    <tr>
      <th class="address-id-hd">ID</th>
      <th class="address-description-hd"><!-- TMPL_VAR description-lb --></th>
      <th class="address-link-hd">       <!-- TMPL_VAR link-lb -->       </th>
      <th class="address-op-link-hd">    <!-- TMPL_VAR operations-lb -->  </th>
    </tr>
  </thead>
  <tbody>
  <!-- TMPL_LOOP data-table -->
  <tr>
    <td class="map-id">
      <!-- TMPL_VAR id -->
    </td>
    <td class="map-description">
      <!-- TMPL_VAR description -->
    </td>
    <td class="map-link">
      <a href="<!-- TMPL_VAR link -->" target="_blank">
	<!-- TMPL_INCLUDE 'ext-link-button.tpl' -->
      </a>
    </td>
    <td class="hazard-delete-link">
      <a href="<!-- TMPL_VAR delete-link -->">
	<!-- TMPL_INCLUDE 'delete-button.tpl' -->
      </a>

      <script>
    $(function() {
	// Shorthand for $( document ).ready()
	$( "#fieldset-subst-map-file<!-- TMPL_VAR id -->" ).dialog({
	    show:  { effect: false },
	    title: "<!-- TMPL_VAR substitute-map-lb -->",
	    autoOpen: false
	});

	$( "#button-subst-map-file<!-- TMPL_VAR id -->").click(function(){
	    $( "#fieldset-subst-map-file<!-- TMPL_VAR id -->" ).dialog("open");
	});
    });
      </script>


      <a href="#"
	 id="button-subst-map-file<!-- TMPL_VAR id -->">
	<!-- TMPL_INCLUDE 'add-map-button.tpl' -->
      </a>

      <div
	 id="fieldset-subst-map-file<!-- TMPL_VAR id -->">
	<form method="POST" ACTION="<!-- TMPL_VAR path-prefix -->/subst-map-file/<!-- TMPL_VAR id -->"
	      enctype="multipart/form-data">
	  <input id="map-file" type="file" name="<!-- TMPL_VAR file -->" />
	  <input type="submit" />
	</form>
      </div>
      <a href="<!-- TMPL_VAR update-map-link -->">
	<!-- TMPL_INCLUDE 'edit-button.tpl' -->
      </a>
      <a href="<!-- TMPL_VAR sensors-map-link -->">
	<i class="fa fa-thermometer fa-2x table-button" aria-hidden="true"></i>
      </a>
    </td>
  </tr>
  <!-- /TMPL_LOOP  -->
  </tbody>
</table>
