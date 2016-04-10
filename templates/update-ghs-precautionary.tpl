<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/update-p/<!-- TMPL_VAR id -->">
  <div>
    <label for="update-p-phrase-id">ID</label>
    <input type="text" id="update-precautionary-phrase-id" value="<!-- TMPL_VAR id -->"
	   disabled="true"/>
    <label for="code-text">Code</label>
    <input id="code-text" type="text" name="<!-- TMPL_VAR code -->"
	   value="<!-- TMPL_VAR code-value -->"/>
    <label for="expl-text">Statement</label>
    <input id="expl-text" type="text" name="<!-- TMPL_VAR expl -->"
	   value="<!-- TMPL_VAR expl-value -->" />
    <input type="submit" />
  </div>
</form>
