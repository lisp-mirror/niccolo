<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/update-sensor/<!-- TMPL_VAR id -->">
  <label for="update-chemical-id">ID</label>
  <input type="text"
	 id="update-storage-id"
	 value="<!-- TMPL_VAR id -->"
	 disabled="true"/>
  <label for="description-text"><!-- TMPL_VAR description-lb --></label>
  <input id="description-text" type="text"
	 value="<!-- TMPL_VAR description-value -->"
	 name="<!-- TMPL_VAR description -->" />
  <label for="address-text"><!-- TMPL_VAR address-lb --></label>
  <input id="address-text" type="text"
	 value="<!-- TMPL_VAR address-value -->"
	 name="<!-- TMPL_VAR address -->" />
  <label for="path-text"><!-- TMPL_VAR path-lb --></label>
  <input id="path-text" type="text"
	 value="<!-- TMPL_VAR path-value -->"
	 name="<!-- TMPL_VAR path -->" />
  <label for="secret-text"><!-- TMPL_VAR secret-lb --></label>
  <input id="secret-text" type="password"
	 value="<!-- TMPL_VAR secret-value -->"
	 name="<!-- TMPL_VAR secret -->" />
  <label for="script-text"><!-- TMPL_VAR script-lb --></label>
  <input id="script-text" type="text"
	 value="<!-- TMPL_VAR script-value -->"
	 name="<!-- TMPL_VAR script -->" />
  <input type="submit" />

</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->
