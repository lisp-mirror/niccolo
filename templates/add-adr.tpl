<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/add-adr/">
  <label for="code-class-text"><!-- TMPL_VAR class-lb --></label>
  <input id="code-class-text" type="text" name="<!-- TMPL_VAR code-class -->" />
  <label for="uncode-text"><!-- TMPL_VAR un-code-lb --></label>
  <input id="uncode-text" type="text" name="<!-- TMPL_VAR uncode -->" />
  <label for="expl-text"><!-- TMPL_VAR explanation-lb --></label>
  <input id="expl-text" type="text" name="<!-- TMPL_VAR expl -->" />
  <input type="submit" />
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->

<table class="sortable adr-list">
  <thead>
    <tr>
      <th class="adr-id-hd">ID</th>
      <th class="adr-code-class-hd"><!-- TMPL_VAR class-lb --></th>
      <th class="adr-uncode-class-hd"><!-- TMPL_VAR uncode-ex-lb --></th>
      <th class="adr-name-hd"><!-- TMPL_VAR proper-shipping-lb --></th>
      <th class="adr-delete-link-d"><!-- TMPL_VAR delete-lb --></th>
    </tr>
  </thead>
  <tbody>
    <!-- TMPL_LOOP data-table -->
    <tr>
      <td class="adr-id"><!-- TMPL_VAR id --></td>
      <td class="adr-code-class">
	<!-- TMPL_VAR code-class -->
	<!-- TMPL_IF pictogram -->
	<img class="pict-preview" src="<!-- TMPL_VAR pictogram -->" />
	<!-- /TMPL_IF -->
      </td>
      <td class="adr-uncode"><!-- TMPL_VAR uncode --></td>
      <td class="adr-name"><!-- TMPL_VAR explanation --></td>
      <td class="adr-delete-link">

      <script>
        $(function() {
	    // Shorthand for $( document ).ready()
	    $( "#assoc-adr-pict<!-- TMPL_VAR id -->" ).dialog({
		show:  { effect: false },
		title: "Associate ADR pictogram",
		autoOpen: false
	    });

	    $( "#button-assoc-adr-pict<!-- TMPL_VAR id -->").click(function(){
		$( "#assoc-adr-pict<!-- TMPL_VAR id -->" ).dialog("open");
	    });
	});
	</script>

	<a href="#" id="button-assoc-adr-pict<!-- TMPL_VAR id -->">
	  <div class="ghs-haz-button">&nbsp;</div>
	</a>

	<div id="assoc-adr-pict<!-- TMPL_VAR id -->">
	    <form method="GET"
		  ACTION="<!-- TMPL_VAR path-prefix -->/assoc-adr-pictogram/<!-- TMPL_VAR id -->">
		<input type  = "hidden"
		       name  = "<!-- TMPL_VAR start-from-name -->"
		       value = "<!-- TMPL_VAR start-from-value -->" />
		<!-- TMPL_LOOP pictogram-buttons -->
		<button type="submit" name="pictogram" value="<!-- TMPL_VAR pict-id -->">
		    <img src="<!-- TMPL_VAR path -->"   />
		</button>
		<!-- /TMPL_LOOP  -->
	    </form>
	</div>

	<a href="<!-- TMPL_VAR delete-link -->">
	  <!-- TMPL_INCLUDE 'delete-button.tpl' -->
	</a>
      </td>
    </tr>
    <!-- /TMPL_LOOP  -->
  </tbody>
</table>

<!-- TMPL_INCLUDE 'pagination-navigation.tpl' -->
