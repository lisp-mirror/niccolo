<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/add-laboratory/">
  <label for="name-text"><!-- TMPL_VAR name-lb --></label>
  <input id="name-text" type="text" name="<!-- TMPL_VAR name -->" />
  <input type="submit" />
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->

<table class="sortable ghs-hazard-list">
  <thead>
  <tr>
    <th class="lab-id-hd">ID</th>
    <th class="lab-name-hd"><!-- TMPL_VAR name-lb --></th>
    <th class="lab-owner-hd"><!-- TMPL_VAR owner-lb --></th>
    <th class="lab-operations-hd"><!-- TMPL_VAR operations-lb --></th>
  </tr>
  </thead>
  <tbody>
  <!-- TMPL_LOOP data-table -->
  <tr>
    <td class="lab-id"><!-- TMPL_VAR id --></td>
    <td class="lab-name"><!-- TMPL_VAR name --></td>
    <td class="lab-owner"><!-- TMPL_VAR owner-user --></td>
    <td class="lab-operations">
      <a href="<!-- TMPL_VAR delete-link -->">
	<!-- TMPL_INCLUDE 'delete-button.tpl' -->
      </a>
    </td>
  </tr>
  <!-- /TMPL_LOOP  --> <!-- data table -->
  </tbody>
</table>

<!-- TMPL_INCLUDE 'pagination-navigation.tpl' -->
