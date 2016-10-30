<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/update-address/<!-- TMPL_VAR id -->">
  <label for="update-chemical-id">ID</label>
  <input type="text" id="update-address-id" value="<!-- TMPL_VAR id -->"
	 disabled="true"/>
  <label for="line-1-text"><!-- TMPL_VAR address-lb --></label>
  <input id="line-1-text" type="text" name="<!-- TMPL_VAR line-1 -->"
	 value="<!-- TMPL_VAR line-1-value -->" />
  <label for="city-text"><!-- TMPL_VAR city-lb --></label>
  <input id="city-text" type="text" name="<!-- TMPL_VAR city -->"
	 value="<!-- TMPL_VAR city-value -->" />
  <label for="zipcode-text"><!-- TMPL_VAR zipcode-lb --></label>
  <input id="zipcode-text" type="text" name="<!-- TMPL_VAR zipcode -->"
	 value="<!-- TMPL_VAR zipcode-value -->" />
  <label for="link-text"><!-- TMPL_VAR weblink-lb --></label>
  <input id="link-text" type="text" name="<!-- TMPL_VAR link -->"
	 value="<!-- TMPL_VAR link-value -->" />
  <input type="submit" />
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->
