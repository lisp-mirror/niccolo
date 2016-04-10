<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<form method="POST" ACTION="<!-- TMPL_VAR path-prefix -->/add-map/" enctype="multipart/form-data">
  <label for="desc-text">Description</label>
  <input id="desc-text" type="text" name="<!-- TMPL_VAR desc -->" />
  <label for="map-file">Map file</label>
  <input id="map-file" type="file" name="<!-- TMPL_VAR data -->" />
  <input type="submit" />
</form>

<table class="sortable map-list">
  <thead>
    <tr>
      <th class="address-id-hd">Id</th>
      <th class="address-description-hd">Description</th>
      <th class="address-link-hd">Link</th>
      <th class="address-op-link-hd">Operation</th>
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
	<div class="link-button">
	  &nbsp;
	</div>
      </a>
    </td>
    <td class="hazard-delete-link">
      <a href="<!-- TMPL_VAR delete-link -->">
	<div class="delete-button">
	  &nbsp;
	</div>
      </a>

      <script>
    $(function() {
	// Shorthand for $( document ).ready()
	$( "#fieldset-subst-map-file<!-- TMPL_VAR id -->" ).dialog({
	    show:  { effect: false },
	    title: "Substitute map file",
	    autoOpen: false
	});

	$( "#button-subst-map-file<!-- TMPL_VAR id -->").click(function(){
	    $( "#fieldset-subst-map-file<!-- TMPL_VAR id -->" ).dialog("open");
	});
    });
      </script>


      <a href="#"
	 id="button-subst-map-file<!-- TMPL_VAR id -->">
	<div class="add-map-file-button">&nbsp;</div>
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
	<div class="edit-button">&nbsp;</div>
      </a>
    </td>
  </tr>
  <!-- /TMPL_LOOP  -->
  </tbody>
</table>
