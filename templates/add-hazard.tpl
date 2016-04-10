<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/add-ghs-hazard/">
  <label for="code-text">Code</label>
  <input id="code-text" type="text" name="<!-- TMPL_VAR code -->" />
  <label for="expl-text">Statement</label>
  <input id="expl-text" type="text" name="<!-- TMPL_VAR expl -->" />
  <label for="carcinogenic-chk">Carcinogenic?</label>
  <input id="carcinogenic-chk" type="text" name="<!-- TMPL_VAR carcinogenic -->" />
  <input type="submit" />
</form>

<table class="sortable ghs-hazard-list">
  <thead>
  <tr>
    <th class="hazard-id-hd">ID</th>
    <th class="hazard-code-hd">Code</th>
    <th class="hazard-name-hd">Statement</th>
    <th class="hazard-carcinogenic-hd">Carcinogenic (according to IARC)</th>
    <th class="hazard-operations-hd">Operation</th>
  </tr>
  </thead>
  <tbody>
  <!-- TMPL_LOOP data-table -->
  <tr>
    <td class="hazard-id"><!-- TMPL_VAR id --></td>
    <td class="hazard-code">
      <!-- TMPL_VAR code -->
      <!-- TMPL_IF pictogram -->
      <img class="pict-preview" src="<!-- TMPL_VAR pictogram -->" />
      <!-- /TMPL_IF -->
    </td>
    <td class="hazard-name"><!-- TMPL_VAR explanation --></td>
    <td class="hazard-carcinogenic"><!-- TMPL_VAR carcinogenic --></td>
    <td class="hazard-operations">
      <a href="<!-- TMPL_VAR delete-link -->">
      <div class="delete-button">
	&nbsp;
      </div>
      </a>

      <script>
        $(function() {
	    // Shorthand for $( document ).ready()
	    $( "#assoc-ghs-pict<!-- TMPL_VAR id -->" ).dialog({
		show:  { effect: false },
		title: "Associate GHS pictogram",
		autoOpen: false
	    });

	    $( "#button-assoc-ghs-pict<!-- TMPL_VAR id -->").click(function(){
		$( "#assoc-ghs-pict<!-- TMPL_VAR id -->" ).dialog("open");
	    });
	});
	</script>

	<a href="#" id="button-assoc-ghs-pict<!-- TMPL_VAR id -->">
	  <div class="ghs-haz-button">&nbsp;</div>
	</a>

	<div id="assoc-ghs-pict<!-- TMPL_VAR id -->">
	  <form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/assoc-ghs-pictogram/<!-- TMPL_VAR id -->">
	    <!-- TMPL_LOOP pictogram-buttons -->
	    <button type="submit" name="pictogram" value="<!-- TMPL_VAR pict-id -->">
	      <img src="<!-- TMPL_VAR path -->"   />
	    </button>
	    <!-- /TMPL_LOOP  -->
	  </form>
	</div>

	<!-- edit statement -->
	<a href="<!-- TMPL_VAR update-link -->">
	  <div class="edit-button">&nbsp;</div>
	</a>


    </td>
  </tr>
  <!-- /TMPL_LOOP  --> <!-- data table -->
  </tbody>
</table>
