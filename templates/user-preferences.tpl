<form method="POST" action="<!-- TMPL_VAR path-prefix -->/user-change-locale/">
  <h3>
    <!-- TMPL_VAR choose-lang-lb -->
  </h3>
  <select id="locale" name="locale">
    <!-- TMPL_LOOP available-locales -->
    <option value="<!-- TMPL_VAR locale-key -->">
      <!-- TMPL_VAR locale-description -->
    </option>
    <!-- /TMPL_LOOP  -->
  </select>
  <input type="submit" />
</form>

<h3><!-- TMPL_VAR change-email-hd --></h3>
<form method="POST" action="<!-- TMPL_VAR path-prefix -->/user-change-email/">
  <label for="login-email"><!-- TMPL_VAR email-lb --></label>
  <input id="login-email" type="text"
	 name="<!-- TMPL_VAR login-email -->"
	 value="<!-- TMPL_VAR login-email-value -->">

  <input type="submit" />
</form>
