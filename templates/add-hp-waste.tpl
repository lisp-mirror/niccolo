<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/add-hp-waste/">
  <label for="code-text"><!-- TMPL_VAR code-lb --></label>
  <input id="code-text" type="text" name="<!-- TMPL_VAR code -->" />
  <label for="expl-text"><!-- TMPL_VAR statement-lb --></label>
  <input id="expl-text" type="text" name="<!-- TMPL_VAR expl -->" />
  <input type="submit" />
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->

<table class="sortable ghs-hazard-list">
  <thead>
  <tr>
    <th class="hp-waste-id-hd">ID</th>
    <th class="hp-waste-code-hd">        <!-- TMPL_VAR code-lb --></th>
    <th class="hp-waste-name-hd">        <!-- TMPL_VAR statement-lb --></th>
    <th class="hp-waste-operations-hd">  <!-- TMPL_VAR operations-lb --></th>
  </tr>
  </thead>
  <tbody>
  <!-- TMPL_LOOP data-table -->
  <tr>
    <td class="hp-waste-id"><!-- TMPL_VAR id --></td>
    <td class="hp-waste-code">
      <!-- TMPL_VAR code -->
    </td>
    <td class="hp-waste-name">        <!-- TMPL_VAR explanation --></td>
    <td class="hp-waste-operations">
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
