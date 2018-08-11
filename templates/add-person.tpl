<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

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

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/add-person/">
    <label for="name-text"><!-- TMPL_VAR name-lb --></label>
    <input id="name-text" type="text" name="<!-- TMPL_VAR name -->" />

    <label for="surname-text"><!-- TMPL_VAR surname-lb --></label>
    <input id="surname-text" type="text" name="<!-- TMPL_VAR surname -->" />

    <label for="organization-text"><!-- TMPL_VAR organization-lb --></label>
    <input id="organization-text" type="text" name="<!-- TMPL_VAR organization -->" />

    <label for="official-id-text"><!-- TMPL_VAR official-id-lb --></label>
    <input id="official-id-text" type="text" name="<!-- TMPL_VAR official-id -->" />

    <label for="person-email"><!-- TMPL_VAR email-lb --></label>
    <input id="person-email" type="text" name="<!-- TMPL_VAR email -->">

    <label for="target-address"
           class="input-autocomplete-label">
        <!-- TMPL_VAR address-lb -->
    </label>
    <input id="target-address-id" type="hidden" name="<!-- TMPL_VAR address-id -->" />
    <span class="ui-widget">
        <input type="text" id="target-address"/>
    </span>

    <input type="submit" />
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->

<table class="sortable building-list">
    <thead>
        <tr>
            <th class="person-name-hd"><!-- TMPL_VAR name-lb --></th>
            <th class="person-address-hd"><!-- TMPL_VAR address-lb --></th>
            <th class="person-organization-hd"><!-- TMPL_VAR organization-lb --></th>
            <th class="person-operations"><!-- TMPL_VAR operations-lb --></th>
        </tr>
    </thead>
    <tbody>
        <!-- TMPL_LOOP data-table -->
        <tr>
            <td class="person-name">
                <!-- TMPL_VAR name -->
                <!-- TMPL_VAR surname -->
                <div>
                    <!-- TMPL_VAR official-id -->
                </div>
            </td>
            <td class="person-address">
                <!-- TMPL_VAR complete-address -->
            </td>
            <td class="person-organization">
                <!-- TMPL_VAR organization -->
            </td>
            <td class="person-delete-link">
                <a href="<!-- TMPL_VAR delete-link -->">
                    <!-- TMPL_INCLUDE 'delete-button.tpl' -->
                </a>
                <a href="<!-- TMPL_VAR update-link -->">
                    <!-- TMPL_INCLUDE 'edit-button.tpl' -->
                </a>
            </td>
        </tr>
        <!-- /TMPL_LOOP  -->
    </tbody>
</table>
