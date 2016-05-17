<form method="POST" action="<!-- TMPL_VAR path-prefix -->/actual-user-change-pass/">
<label for="old-password"><!-- TMPL_VAR old-password-lb --></label>
<input id="old-password" type="password" name="<!-- TMPL_VAR old-password -->">
<label for="password"><!-- TMPL_VAR new-password-lb --></label>
<input id="password" type="password" name="<!-- TMPL_VAR password -->">
<label for="password-2"><!-- TMPL_VAR confirm-new-password-lb --></label>
<input id="password-2" type="password" name="<!-- TMPL_VAR password-2 -->">

<input id="login-submit" type="submit">
</form>
