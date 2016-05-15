<form method="POST" action="<!-- TMPL_VAR path-prefix -->/user-change-locale/">
  <label for="locale">
    <!-- TMPL_VAR choose-lang-lb -->
  </label>
  <select id="locale" name="locale">
    <!-- TMPL_LOOP available-locales -->
    <option value="<!-- TMPL_VAR locale-key -->">
      <!-- TMPL_VAR locale-description -->
    </option>
    <!-- /TMPL_LOOP  -->
  </select>
  <input type="submit" />
</form>
