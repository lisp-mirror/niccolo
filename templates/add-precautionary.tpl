<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/add-ghs-precautionary/">
  <label for="code-text"><!-- TMPL_VAR code-lb --></label>
  <input id="code-text" type="text" name="<!-- TMPL_VAR code -->" />
  <label for="expl-text"><!-- TMPL_VAR statement-lb --></label>
  <input id="expl-text" type="text" name="<!-- TMPL_VAR expl -->" />
  <input type="submit" />
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->

<table class="sortable ghs-precautionary-list">
  <thead>
    <tr>
      <th class="precautionary-id-hd">ID</th>
      <th class="precautionary-code-hd"><!-- TMPL_VAR code-lb --></th>
      <th class="precautionary-name-hd"><!-- TMPL_VAR statement-lb --></th>
      <th class="precautionary-delete-link-d"><!-- TMPL_VAR operations-lb --></th>
    </tr>
  </thead>
  <tbody>
    <!-- TMPL_LOOP data-table -->
    <tr>
      <td class="precautionary-id"><!-- TMPL_VAR id --></td>
      <td class="precautionary-code"><!-- TMPL_VAR code --></td>
      <td class="precautionary-name"><!-- TMPL_VAR explanation --></td>
      <td class="precautionary-delete-link">
	<a href="<!-- TMPL_VAR delete-link -->">
	  <!-- TMPL_INCLUDE 'delete-button.tpl' -->
	</a>
	<!-- edit statement -->
	<a href="<!-- TMPL_VAR update-link -->">
	  <!-- TMPL_INCLUDE 'edit-button.tpl' -->
	</a>

      </td>
    </tr>
    <!-- /TMPL_LOOP  -->
  </tbody>
</table>

<!-- TMPL_INCLUDE 'pagination-navigation.tpl' -->
