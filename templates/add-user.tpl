<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<form method="POST" action="<!-- TMPL_VAR path-prefix -->/add-user/">
<label for="login-name"><!-- TMPL_VAR name-lb --></label>
<input id="login-name" type="text" name="<!-- TMPL_VAR login-name -->">
<label for="login-name"><!-- TMPL_VAR password-lb --></label>
<input id="login-password" type="password" name="<!-- TMPL_VAR login-pass -->">
<input id="login-submit" type="submit" value="Add user">
</form>


<table class="sortable user-list">
  <thead>
    <tr>
      <th class="name-hd"><!-- TMPL_VAR name-lb --></th>
      <th class="user-op-hd"><!-- TMPL_VAR operation-lb --></th>
    </tr>
  </thead>
  <tbody>
  <!-- TMPL_LOOP data-table -->
  <tr>
    <td class="name">
      <!-- TMPL_VAR username -->
    </td>
    <td class="address-delete-link">
      <a href="<!-- TMPL_VAR delete-link -->">
	<div class="delete-button">
	  &nbsp;
	</div>
      </a>
    </td>
  </tr>
  <!-- /TMPL_LOOP  -->
  </tbody>
</table>
