<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/add-cer/">
  <label for="code-text"><!-- TMPL_VAR code-lb --></label>
  <input id="code-text" type="text" name="<!-- TMPL_VAR code -->" />
  <label for="expl-text"><!-- TMPL_VAR explanation-lb --></label>
  <input id="expl-text" type="text" name="<!-- TMPL_VAR expl -->" />
  <input type="submit" />
</form>

<table class="sortable cer-list">
  <thead>
    <tr>
      <th class="cer-id-hd">ID</th>
      <th class="cer-code-hd"><!-- TMPL_VAR code-lb --></th>
      <th class="cer-name-hd"><!-- TMPL_VAR statement-lb --></th>
      <th class="cer-delete-link-d"><!-- TMPL_VAR delete-lb --></th>
    </tr>
  </thead>
  <tbody>
    <!-- TMPL_LOOP data-table -->
    <tr>
      <td class="cer-id"><!-- TMPL_VAR id --></td>
      <td class="cer-code"><!-- TMPL_VAR code --></td>
      <td class="cer-name"><!-- TMPL_VAR explanation --></td>
      <td class="cer-delete-link">
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
