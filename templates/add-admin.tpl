<form method="POST" action="<!-- TMPL_VAR path-prefix -->/actual-admin-change-pass/">

  <label for="password">Username:</label>
  <input id="password" type="text" name="<!-- TMPL_VAR user-name -->">
  <label for="password-2">Email:</label>
  <input id="password-2" type="text" name="<!-- TMPL_VAR email -->">


  <label for="password">New password:</label>
  <input id="password" type="password" name="<!-- TMPL_VAR password -->">

  <label for="password-2">Confirm new password:</label>
  <input id="password-2" type="password" name="<!-- TMPL_VAR password-2 -->">

  <input id="login-submit" type="submit">
</form>
