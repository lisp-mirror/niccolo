<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/broadcast-message/">
  <label for="name-subject"><!-- TMPL_VAR subject-lb --></label>
  <input id="name-subject" type="text" name="<!-- TMPL_VAR subject -->" />

  <div>
    <div><label for="textarea-body-message"><!-- TMPL_VAR body-lb --></label></div>
    <textarea id="textarea-body-message"
	      cols='70' rows='30'
	      name="<!-- TMPL_VAR body -->"></textarea>
    <input type="submit" />
  </div>

</form>
