<script>
    $(function() {
	$( "#validity-date" ).datepicker({dateFormat : "yy-mm-dd"});
	$( "#expire-date" ).datepicker({dateFormat : "yy-mm-dd"});
	$( "#opening-package-date" ).datepicker({dateFormat : "yy-mm-dd"});
    })

</script>

<form method="GET" ACTION=""/>
  <div>
    <label for="update-chemical-id">ID</label>
    <input type="text" id="update-chemical-id" value="<!-- TMPL_VAR id -->"
	   disabled="true"/>

    <label for="quantity"><!-- TMPL_VAR quantity-lb --></label>
    <input id="quantity" type="text"
	   name="<!-- TMPL_VAR quantity -->"
	   value="<!-- TMPL_VAR quantity-value -->" />

    <label for="units"><!-- TMPL_VAR units-lb --></label>
    <input id="units" type="text"
	   name="<!-- TMPL_VAR units -->"
	   value="<!-- TMPL_VAR units-value -->" />

    <label for="validity-date"><!-- TMPL_VAR validity-date-lb --></label>
    <input id="validity-date"
	   type="text"
	   name="<!-- TMPL_VAR validity-date -->"
	   value="<!-- TMPL_VAR validity-date-value -->" />

    <label for="expire-date"><!-- TMPL_VAR expire-date-lb --></label>
    <input id="expire-date"
	   type="text"
	   name="<!-- TMPL_VAR expire-date -->"
	   value="<!-- TMPL_VAR expire-date-value -->" />

    <label for="opening-package-date"><!-- TMPL_VAR opening-package-date-lb --></label>
    <input id="opening-package-date"
	   type="text"
	   name="<!-- TMPL_VAR opening-package-date -->"
	   value="<!-- TMPL_VAR opening-package-date-value -->" />

    <input type="submit" />
  </div>
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->
