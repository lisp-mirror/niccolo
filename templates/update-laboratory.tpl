<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/update-laboratory/<!-- TMPL_VAR id -->">
  <div>
    <label for="update-lab-id">ID</label>
    <input type="text" id="update-laboratory-id" value="<!-- TMPL_VAR id -->"
	   disabled="true"/>
    <label for="name-text"><!-- TMPL_VAR name-lb --></label>
    <input id="name-text" type="text" name="<!-- TMPL_VAR name -->"
	   value="<!-- TMPL_VAR name-value -->"/>
    <label for="complete-name-text"><!-- TMPL_VAR complete-name-lb --></label>
    <input id="complete-name-text" type="text" name="<!-- TMPL_VAR complete-name -->"
	   value="<!-- TMPL_VAR complete-name-value -->"/>
    <input type="submit" />
  </div>
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->
