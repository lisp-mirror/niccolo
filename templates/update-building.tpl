<script>
    // Shorthand for $( document ).ready()
    $(function() {
	var availableAddr = <!-- TMPL_VAR json-addresses -->;
	var availableId   = <!-- TMPL_VAR json-addresses-id -->;
	$( "#target-address" ).autocomplete({
	    source: availableAddr ,
	    select: function( event, ui ) {
		var idx = $.inArray(ui.item.label, availableAddr);
		$("#target-address-id").val(availableId[idx]);
	    }
	});
    });
</script>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/update-building/<!-- TMPL_VAR id -->">
  <label for="update-chemical-id">ID</label>
  <input type="text"
	 id="update-building-id"
	 value="<!-- TMPL_VAR id -->"
	 disabled="true"/>
  <label for="name-text"><!-- TMPL_VAR name-lb --></label>
  <input id="name-text"
	 type="text"
	 value="<!-- TMPL_VAR name-value -->"
	 name="<!-- TMPL_VAR name -->" />
  <label for="target-address"><!-- TMPL_VAR address-lb --></label>
  <input id="target-address-id" type="hidden"
	 value="<!-- TMPL_VAR address-id-value -->"
	 name="<!-- TMPL_VAR address-id -->" />
  <span class="ui-widget">
    <input type="text" id="target-address"
	   value="<!-- TMPL_VAR address-value -->"/>
  </span>
  <input type="submit" />
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->
