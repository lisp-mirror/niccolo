<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/add-waste-phys-state/">
  <label for="expl-text"><!-- TMPL_VAR explanation-lb --></label>
  <input id="expl-text" type="text" name="<!-- TMPL_VAR expl -->" />
  <input type="submit" />
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->

<table class="sortable ghs-hazard-list">
  <thead>
  <tr>
    <th class="waste-phys-state-id-hd">ID</th>
    <th class="waste-phys-state-name-hd">        <!-- TMPL_VAR explanation-lb --></th>
    <th class="waste-phys-state-operations-hd">  <!-- TMPL_VAR operations-lb --> </th>
  </tr>
  </thead>
  <tbody>
  <!-- TMPL_LOOP data-table -->
  <tr>
    <td class="waste-phys-state-id">          <!-- TMPL_VAR id -->         </td>
    <td class="waste-phys-state-name">        <!-- TMPL_VAR explanation --></td>
    <td class="waste-phys-state-operations">
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
  <!-- /TMPL_LOOP  --> <!-- data table -->
  </tbody>
</table>
