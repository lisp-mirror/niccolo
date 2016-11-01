<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/add-adr/">
  <label for="code-class-text"><!-- TMPL_VAR class-lb --></label>
  <input id="code-class-text" type="text" name="<!-- TMPL_VAR code-class -->" />
  <label for="uncode-text"><!-- TMPL_VAR un-code-lb --></label>
  <input id="uncode-text" type="text" name="<!-- TMPL_VAR uncode -->" />
  <label for="expl-text"><!-- TMPL_VAR explanation-lb --></label>
  <input id="expl-text" type="text" name="<!-- TMPL_VAR expl -->" />
  <input type="submit" />
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->

<table class="sortable adr-list">
  <thead>
    <tr>
      <th class="adr-id-hd">ID</th>
      <th class="adr-code-class-hd"><!-- TMPL_VAR class-lb --></th>
      <th class="adr-uncode-class-hd"><!-- TMPL_VAR uncode-ex-lb --></th>
      <th class="adr-name-hd"><!-- TMPL_VAR proper-shipping-lb --></th>
      <th class="adr-delete-link-d"><!-- TMPL_VAR delete-lb --></th>
    </tr>
  </thead>
  <tbody>
    <!-- TMPL_LOOP data-table -->
    <tr>
      <td class="adr-id"><!-- TMPL_VAR id --></td>
      <td class="adr-code-class"><!-- TMPL_VAR code-class --></td>
      <td class="adr-uncode"><!-- TMPL_VAR uncode --></td>
      <td class="adr-name"><!-- TMPL_VAR explanation --></td>
      <td class="adr-delete-link">
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
