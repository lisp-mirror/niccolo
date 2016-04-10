<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/add-ghs-precautionary/">
  <label for="code-text">Code</label>
  <input id="code-text" type="text" name="<!-- TMPL_VAR code -->" />
  <label for="expl-text">Statement</label>
  <input id="expl-text" type="text" name="<!-- TMPL_VAR expl -->" />
  <input type="submit" />
</form>

<table class="sortable ghs-precautionary-list">
  <thead>
    <tr>
      <th class="precautionary-id-hd">ID</th>
      <th class="precautionary-code-hd">Code</th>
      <th class="precautionary-name-hd">Statement</th>
      <th class="precautionary-delete-link-d">Delete</th>
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
	  <div class="delete-button">
	    &nbsp;
	  </div>
	</a>
	<!-- edit statement -->
	<a href="<!-- TMPL_VAR update-link -->">
	  <div class="edit-button">&nbsp;</div>
	</a>

      </td>
    </tr>
    <!-- /TMPL_LOOP  -->
  </tbody>
</table>
