<script>
    $(function() {
	$( "#validity-date" ).datepicker({dateFormat : "yy-mm-dd"});
	$( "#expire-date" ).datepicker({dateFormat : "yy-mm-dd"});
    })

</script>

<form method="GET" ACTION=""/>
  <div>
    <label for="update-chemical-id">ID</label>
    <input type="text" id="update-chemical-id" value="<!-- TMPL_VAR id -->"
	   disabled="true"/>
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
    <input type="submit" />
  </div>
</form>
