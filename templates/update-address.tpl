<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/update-address/<!-- TMPL_VAR id -->">
  <label for="update-chemical-id">ID</label>
  <input type="text" id="update-address-id" value="<!-- TMPL_VAR id -->"
	 disabled="true"/>
  <label for="line-1-text">Address</label>
  <input id="line-1-text" type="text" name="<!-- TMPL_VAR line-1 -->"
	 value="<!-- TMPL_VAR line-1-value -->" />
  <label for="city-text">City</label>
  <input id="city-text" type="text" name="<!-- TMPL_VAR city -->"
	 value="<!-- TMPL_VAR city-value -->" />
  <label for="zipcode-text">Zipcode</label>
  <input id="zipcode-text" type="text" name="<!-- TMPL_VAR zipcode -->"
	 value="<!-- TMPL_VAR zipcode-value -->" />
  <label for="link-text">Weblink</label>
  <input id="link-text" type="text" name="<!-- TMPL_VAR link -->"
	 value="<!-- TMPL_VAR link-value -->" />
  <input type="submit" />
</form>
