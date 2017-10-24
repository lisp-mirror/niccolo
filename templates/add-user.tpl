<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<form method="POST" action="<!-- TMPL_VAR path-prefix -->/add-user/">
  <label for="login-name"><!-- TMPL_VAR name-lb --></label>
  <input id="login-name" type="text" name="<!-- TMPL_VAR login-name -->">

  <label for="login-email"><!-- TMPL_VAR email-lb --></label>
  <input id="login-email" type="text" name="<!-- TMPL_VAR login-email -->">

  <label for="login-name"><!-- TMPL_VAR password-lb --></label>
  <input id="login-password" type="password"
	 name="<!-- TMPL_VAR login-pass -->"
	 value="<!-- TMPL_VAR password-value -->">
  <label for="levels-select"><!-- TMPL_VAR levels-options-lb --></label>
  <select id="levels-select" name="<!-- TMPL_VAR levels-select -->">
    <option value="-1"></option>
    <!-- TMPL_LOOP level-options -->
    <option value="<!-- TMPL_VAR level -->"><!-- TMPL_VAR expl --></option>
    <!-- /TMPL_LOOP  -->
  </select>
  <input id="login-submit" type="submit" value="Add user">
</form>

<table class="sortable user-list">
  <thead>
    <tr>
      <th class="name-hd"><!-- TMPL_VAR name-lb --></th>
      <th class="name-hd"><!-- TMPL_VAR email-lb --></th>
      <th class="level-hd"><!-- TMPL_VAR level-lb --></th>
      <th class="user-op-hd"><!-- TMPL_VAR operations-lb --></th>
    </tr>
  </thead>
  <tbody>
  <!-- TMPL_LOOP data-table -->
  <tr>

    <!-- TMPL_IF active-p -->
    <td class="name">
      <!-- TMPL_VAR username -->
    </td>
    <!-- /TMPL_IF -->

    <!-- TMPL_UNLESS active-p -->
    <td class="name-disabled">
      <!-- TMPL_VAR username -->
    </td>
    <!-- /TMPL_UNLESS -->

    <td class="email">
      <!-- TMPL_VAR email -->
    </td>

    <td class="level">
      <!-- TMPL_VAR level-expl -->
    </td>

    <td class="delete-link">
      <a href="<!-- TMPL_VAR delete-link -->">
	<!-- TMPL_INCLUDE 'delete-button.tpl' -->
      </a>

      <!-- TMPL_IF active-p -->
      <a href="<!-- TMPL_VAR disable-link -->">
	<div class="prohibition-button">
	  &nbsp;
	</div>
      </a>
      <!-- /TMPL_IF -->

      <!-- TMPL_UNLESS active-p -->
      <a href="<!-- TMPL_VAR enable-link -->">
	<div class="activate-button">
	  &nbsp;
	</div>
      </a>
      <!-- /TMPL_UNLESS -->
    </td>

  </tr>
  <!-- /TMPL_LOOP  -->
  </tbody>
</table>
