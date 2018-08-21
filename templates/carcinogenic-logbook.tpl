<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/table2csv.js"></script>

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

     function cleanField (field){
	 return field.replace(/[\s]{2,}/g, "");

     }

     $("#export-csv-local-button").click(function (e){
	 let csv = table2csv("results", cleanField);
	 location.href = "data:text/csv;base64," +  window.btoa(csv);
     });


 });

</script>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/carcinogenic-logbook/">
    <label for="target-labs" class="input-autocomplete-label">
        <!-- TMPL_VAR laboratory-name-lb -->
    </label>
    <input id="target-labs-id" type="hidden" name="<!-- TMPL_VAR labs-id -->" />
    <span class="ui-widget">
        <input type="text" id="target-labs"/>
    </span>

    <input type="submit" />
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->

<a id="export-csv-local-button" class="help-button">
    <!-- TMPL_INCLUDE 'download-button.tpl' -->
</a>

<table class="sortable carcinogenic-log-list" id="results">
    <thead>
        <tr>
            <th class="carcinogenic-id-hd">ID</th>
            <th class="carcinogenic-lab-id-hd"><!-- TMPL_VAR laboratory-id-lb --></th>
            <th class="carcinogenic-lab-hd"><!-- TMPL_VAR laboratory-name-lb --></th>
            <th class="carcinogenic-worker-hd"><!-- TMPL_VAR worker-lb --></th>
            <th class="carcinogenic-worker-code-hd"><!-- TMPL_VAR worker-code-lb --></th>
            <th class="carcinogenic-work-type-hd"><!-- TMPL_VAR work-type-lb --></th>
            <th class="carcinogenic-work-type-code-hd"><!-- TMPL_VAR work-type-code-lb --></th>
            <th class="carcinogenic-work-methods"><!-- TMPL_VAR work-methods-lb --></th>
            <th class="carcinogenic-quantity-hd"><!-- TMPL_VAR quantity-lb --></th>
            <th class="carcinogenic-units-hd"><!-- TMPL_VAR units-lb --></th>
            <th class="carcinogenic-chem-name-hd"><!-- TMPL_VAR chemical-name-lb --></th>
            <th class="carcinogenic-log-canceled-hd"><!-- TMPL_VAR log-canceled-p-lb --></th>
            <th class="carcinogenic-operations-hd"><!-- TMPL_VAR operations-lb --></th>
        </tr>
    </thead>
    <tbody>
        <!-- TMPL_LOOP data-table -->



        <tr <!-- TMPL_IF canceledp -->
            class="strike"
            <!-- /TMPL_IF -->
            >
            <td class="carcinogenic-id"><!-- TMPL_VAR log-id --></td>
            <td class="carcinogenic-lab-id"><!-- TMPL_VAR lab-name --></td>
            <td class="carcinogenic-lab"><!-- TMPL_VAR lab-fullname --></td>
            <td class="carcinogenic-worker"><!-- TMPL_VAR worker --></td>
            <td class="carcinogenic-worker-code"><!-- TMPL_VAR worker-code --></td>
            <td class="carcinogenic-work-type"><!-- TMPL_VAR work-type --></td>
            <td class="carcinogenic-work-type-code"><!-- TMPL_VAR work-type-code --></td>
            <td class="carcinogenic-work-methods"><!-- TMPL_VAR work-methods --></td>
            <td class="carcinogenic-quantity"><!-- TMPL_VAR quantity-rounded --></td>
            <td class="carcinogenic-units"><!-- TMPL_VAR units --></td>
            <td class="carcinogenic-chem-name"><!-- TMPL_VAR chem-name --></td>
            <td class="carcinogenic-log-canceled"><!-- TMPL_VAR canceledp --></td>
            <td class="carcinogenic,-operations">
                <!-- TMPL_UNLESS canceledp -->
                <a href="<!-- TMPL_VAR delete-link -->">
	            <!-- TMPL_INCLUDE 'delete-button.tpl' -->
                </a>
                <!-- /TMPL_UNLESS -->
            </td>
        </tr>
        <!-- /TMPL_LOOP  --> <!-- data table -->
    </tbody>
</table>

<!-- TMPL_INCLUDE 'pagination-navigation.tpl' -->
