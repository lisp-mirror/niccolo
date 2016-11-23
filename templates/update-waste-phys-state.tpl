<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/update-waste-phys-state/<!-- TMPL_VAR id -->">
  <div>
    <label for="update-p-phrase-id">ID</label>
    <input type="text" id="update-hp-waste-code-id" value="<!-- TMPL_VAR id -->"
	   disabled="true"/>
    <label for="expl-text"><!-- TMPL_VAR statement-lb --></label>
    <input id="expl-text" type="text" name="<!-- TMPL_VAR expl -->"
	   value="<!-- TMPL_VAR expl-value -->" />
    <input type="submit" />
  </div>
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->
