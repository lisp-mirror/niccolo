<div class="logout-link">
  <span class="logout-username">
    <!-- TMPL_VAR session-username -->
  </span>
  <!-- TMPL_IF logout-link -->
  <a href="<!-- TMPL_VAR logout-link -->">
    <button class="button-logout">Logout</button>
  </a>
  <!-- /TMPL_IF -->
  <!-- TMPL_IF login-link -->
  <a href="<!-- TMPL_VAR login-link -->">
    <button class="button-login">Login</button>
  </a>
  <!-- /TMPL_IF -->
</div>
