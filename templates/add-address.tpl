<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/add-address/">
  <label for="line-1-text"><!-- TMPL_VAR address-lb --></label>
  <input id="line-1-text" type="text" name="<!-- TMPL_VAR line-1 -->" />
  <label for="city-text">City</label>
  <input id="city-text" type="text" name="<!-- TMPL_VAR city -->" />
  <label for="zipcode-text"><!-- TMPL_VAR zipcode-lb --></label>
  <input id="zipcode-text" type="text" name="<!-- TMPL_VAR zipcode -->" />
  <label for="link-text"><!-- TMPL_VAR link-lb --></label>
  <input id="link-text" type="text" name="<!-- TMPL_VAR link -->" />
  <input type="submit" />
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->

<table class="sortable ghs-hazard-list">
  <thead>
    <tr>
      <th class="address-all-hd"><!-- TMPL_VAR address-lb --></th>
      <th class="address-link-hd"><!-- TMPL_VAR link-lb --></th>
      <th class="address-op-link-hd"><!-- TMPL_VAR operation-lb --></th>
    </tr>
  </thead>
  <tbody>
  <!-- TMPL_LOOP data-table -->
  <tr>
    <td class="address-all">
      <!-- TMPL_VAR line-1 -->
      <!-- TMPL_VAR city -->
      <!-- TMPL_VAR zipcode -->
    </td>
    <td class="address-link">
      <div class="link-button">
	<a href="<!-- TMPL_VAR link -->">
	  &nbsp;
	</a>
      </div>
    </td>
    <td class="address-delete-link">
      <a href="<!-- TMPL_VAR delete-link -->">
	<div class="delete-button">
	  &nbsp;
	</div>
      </a>
      <a href="<!-- TMPL_VAR update-address-link -->">
	<div class="edit-button">&nbsp;</div>
      </a>

    </td>
  </tr>
  <!-- /TMPL_LOOP  -->
  </tbody>
</table>
