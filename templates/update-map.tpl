<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/update-map/<!-- TMPL_VAR id -->">
  <label for="desc-text"><!-- TMPL_VAR description-lb --></label>
  <input id="desc-text" type="text"
	 value="<!-- TMPL_VAR desc-value -->"
	 name="<!-- TMPL_VAR desc -->" />
  <input type="submit" />
</form>
