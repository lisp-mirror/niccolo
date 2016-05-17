<script>
    // Shorthand for $( document ).ready()
    $(function() {
    	var availableBuilding = <!-- TMPL_VAR json-buildings -->;
	var availableId   = <!-- TMPL_VAR json-buildings-id -->;

	$( "#target-building" ).autocomplete({
	    source: availableBuilding ,
	    select: function( event, ui ) {
		var idx = $.inArray(ui.item.label, availableBuilding);
		$("#target-building-id").val(availableId[idx]);
	    }
	});
    });
</script>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/update-storage/<!-- TMPL_VAR id -->">
  <label for="update-chemical-id">ID</label>
  <input type="text"
	 id="update-storage-id"
	 value="<!-- TMPL_VAR id -->"
	 disabled="true"/>
  <label for="name-text"><!-- TMPL_VAR name-lb --></label>
  <input id="name-text"
	 type="text"
	 value="<!-- TMPL_VAR name-value -->"
	 name="<!-- TMPL_VAR name -->" />
  <label for="target-building"><!-- TMPL_VAR building-lb --></label>
  <input id="target-building-id" type="hidden"
	 value="<!-- TMPL_VAR building-id-value -->"
	 name="<!-- TMPL_VAR building-id -->" />
  <span class="ui-widget">
    <input type="text" id="target-building"
	   value="<!-- TMPL_VAR building-value -->"/>
  </span>
  <label for="name-floor"><!-- TMPL_VAR floor-lb --></label>
  <input id="name-floor"
	 type="text"
	 value="<!-- TMPL_VAR floor-value -->"
	 name="<!-- TMPL_VAR floor -->" />

  <input type="submit" />
</form>
