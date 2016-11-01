<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/update-chemical/<!-- TMPL_VAR id -->">
  <div>
    <label for="update-chemical-id">ID</label>
    <input type="text" id="update-chemical-id" value="<!-- TMPL_VAR id -->"
	   disabled="true"/>
    <label for="name-text"><!-- TMPL_VAR name-lb --></label>
    <input id="name-text" type="text" name="<!-- TMPL_VAR name -->"
	   value="<!-- TMPL_VAR name-value -->" />
    <label for="cid-text">Pubchem CID</label>
    <input id="cid-text" type="text" name="<!-- TMPL_VAR cid -->"
	   value="<!-- TMPL_VAR cid-value -->"/>
    <input type="submit" />
  </div>
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->
