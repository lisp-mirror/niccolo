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

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/update-person/<!-- TMPL_VAR id -->">
    <label for="name-text"><!-- TMPL_VAR name-lb --></label>
    <input id="name-text" type="text" name="<!-- TMPL_VAR name -->"
           value="<!-- TMPL_VAR name-value -->"/>

    <label for="surname-text"><!-- TMPL_VAR surname-lb --></label>
    <input id="surname-text" type="text" name="<!-- TMPL_VAR surname -->"
           value="<!-- TMPL_VAR surname-value -->"/>

    <label for="organization-text"><!-- TMPL_VAR organization-lb --></label>
    <input id="organization-text" type="text" name="<!-- TMPL_VAR organization -->"
           value="<!-- TMPL_VAR organization-value -->"/>

    <label for="official-id-text"><!-- TMPL_VAR official-id-lb --></label>
    <input id="official-id-text" type="text" name="<!-- TMPL_VAR official-id -->"
           value="<!-- TMPL_VAR official-id-value -->"/>

    <label for="target-address"
           class="input-autocomplete-label">
        <!-- TMPL_VAR address-lb -->
    </label>

    <input id="target-address-id" type="hidden" name="<!-- TMPL_VAR address-id -->"
           value="<!-- TMPL_VAR address-id-value -->"/>

    <span class="ui-widget">
        <input type="text" id="target-address"
               value="<!-- TMPL_VAR address-value -->"/>
    </span>

    <input type="submit" />
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->
