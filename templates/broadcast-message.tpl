<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/broadcast-message/">
  <label for="name-subject"><!-- TMPL_VAR subject-lb --></label>
  <input id="name-subject" type="text" name="<!-- TMPL_VAR subject -->" />

  <div>
    <div><label for="textarea-body-message"><!-- TMPL_VAR body-lb --></label></div>
    <div id="editor-body-message">
    </div>

    <textarea id="editor-dump"
              name="<!-- TMPL_VAR body -->"></textarea>

    <input type="submit" />
  </div>

</form>

<script src="<!-- TMPL_VAR path-prefix -->/js/pell-init.js"></script>
