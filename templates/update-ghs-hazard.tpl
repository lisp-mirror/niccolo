<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/update-h/<!-- TMPL_VAR id -->">
  <div>
    <label for="update-h-phrase-id">ID</label>
    <input type="text" id="update-hazard-phrase-id" value="<!-- TMPL_VAR id -->"
	   disabled="true"/>
    <label for="code-text"><!-- TMPL_VAR code-lb --></label>
    <input id="code-text" type="text" name="<!-- TMPL_VAR code -->"
	   value="<!-- TMPL_VAR code-value -->"/>
    <label for="expl-text"><!-- TMPL_VAR statement-lb --></label>
    <input id="expl-text" type="text" name="<!-- TMPL_VAR expl -->"
	   value="<!-- TMPL_VAR expl-value -->" />
    <label for="carcinogenic-text"><!-- TMPL_VAR carcinogenic-p-lb --></label>
    <input id="carcinogenic-text" type="text" name="<!-- TMPL_VAR carcinogenic -->"
	   value="<!-- TMPL_VAR carcinogenic-value -->" />
    <input type="submit" />
  </div>
</form>
