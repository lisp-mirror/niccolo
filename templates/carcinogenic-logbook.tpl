<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<script>
 $(function() {
     var availableLabs = <!-- TMPL_VAR json-laboratory -->;
     var availableLabsId   = <!-- TMPL_VAR json-laboratory-id -->;
     $( "#target-labs" ).autocomplete({
         source: availableLabs ,
         select: function( event, ui ) {
             var idx = $.inArray(ui.item.label, availableLabs);
             $("#target-labs-id").val(availableLabsId[idx]);
         }
     });
 })

</script>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/carcinogenic-logbook/">
    <label for="target-labs"
           class="input-autocomplete-label">
        <!-- TMPL_VAR lab-name-lb -->
    </label>
    <input id="target-labs-id" type="hidden" name="<!-- TMPL_VAR labs-id -->" />
    <span class="ui-widget">
        <input type="text" id="target-labs"/>
    </span>

    <input type="submit" />
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->

<table class="sortable carcinogenic-log-list">
    <thead>
        <tr>
            <th class="carcinogenic-id-hd">ID</th>
            <th class="carcinogenic-lab-hd"><!-- TMPL_VAR laboratory-name-lb --></th>
            <th class="carcinogenic-worker-hd"><!-- TMPL_VAR worker-lb --></th>
            <th class="carcinogenic-worker-code-hd"><!-- TMPL_VAR worker-code-lb --></th>
            <th class="carcinogenic-work-type-hd"><!-- TMPL_VAR work-type-lb --></th>
            <th class="carcinogenic-work-type-code-hd"><!-- TMPL_VAR work-type-code-lb --></th>
            <th class="carcinogenic-work-methods"><!-- TMPL_VAR work-methods-lb --></th>
            <th class="carcinogenic-quantity-hd"><!-- TMPL_VAR quantity-lb --></th>
            <th class="carcinogenic-units-hd"><!-- TMPL_VAR units-lb --></th>
            <th class="carcinogenic-chem-name-hd"><!-- TMPL_VAR chemical-name-lb --></th>
            <th class="carcinogenic-operations-hd"><!-- TMPL_VAR operations-lb --></th>
        </tr>
    </thead>
    <tbody>
        <!-- TMPL_LOOP data-table -->



        <tr <!-- TMPL_UNLESS canceledp -->
            class="strike"
            <!-- /TMPL_UNLESS -->
            >
            <td class="carcinogenic-id"><!-- TMPL_VAR log-id --></td>
            <td class="carcinogenic-lab">
                <p><!-- TMPL_VAR lab-fullname --></p>
                <p><b><!-- TMPL_VAR lab-name --></b></p>
            </td>
            <td class="carcinogenic-worker"><!-- TMPL_VAR worker --></td>
            <td class="carcinogenic-worker-code"><!-- TMPL_VAR worker-code --></td>
            <td class="carcinogenic-work-type"><!-- TMPL_VAR work-type --></td>
            <td class="carcinogenic-work-type-code"><!-- TMPL_VAR work-type-code --></td>
            <td class="carcinogenic-work-methods"><!-- TMPL_VAR work-methods --></td>
            <td class="carcinogenic-quantity"><!-- TMPL_VAR quantity-rounded --></td>
            <td class="carcinogenic-units"><!-- TMPL_VAR units --></td>
            <td class="carcinogenic-chem-name"><!-- TMPL_VAR chem-name --></td>

            <td class="carcinogenic,-operations">
                <!-- TMPL_IF canceledp -->
                <a href="<!-- TMPL_VAR delete-link -->">
	            <!-- TMPL_INCLUDE 'delete-button.tpl' -->
                </a>
                <!-- /TMPL_IF -->
            </td>
        </tr>
        <!-- /TMPL_LOOP  --> <!-- data table -->
    </tbody>
</table>

<!-- TMPL_INCLUDE 'pagination-navigation.tpl' -->
