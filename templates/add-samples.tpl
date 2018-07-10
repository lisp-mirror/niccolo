<script src="<!-- TMPL_VAR path-prefix -->/js/place-footer.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/misc.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/sum-product-quantity-dialog.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/get-get.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/table2csv.js"></script>

<script>

 // Shorthand for $( document ).ready()
 $(function() {
     var availablePerson = <!-- TMPL_VAR json-person -->;
     var availableId     = <!-- TMPL_VAR json-person-id -->;
     $( "#target-person" ).autocomplete({
         source: availablePerson ,
         select: function( event, ui ) {
             var idx = $.inArray(ui.item.label, availablePerson);
             $("#target-person-id").val(availableId[idx]);
         }
     });

     $( "#checkin-date" ).datepicker({dateFormat : "yy-mm-dd"});

     $( "#checkout-date" ).datepicker({dateFormat : "yy-mm-dd"});

     var availableLabs = <!-- TMPL_VAR json-laboratory -->;
     var availableLabsId   = <!-- TMPL_VAR json-laboratory-id -->;
     $( "#target-labs" ).autocomplete({
         source: availableLabs ,
         select: function( event, ui ) {
             var idx = $.inArray(ui.item.label, availableLabs);
             $("#target-labs-id").val(availableLabsId[idx]);
         }
     });

     // let's try to align button
     var addPos= $( "#submit-add" ).position();
     $( "#submit-search").css("position", "absolute");
     $( "#submit-search").css("top", addPos.top);
     $( ".search-chem-prod").height(addPos.top);
     $( ".add-new-chem-prod").height(addPos.top);
     $( ".other-ops-chem-prod").height(addPos.top);

     placeFooter();
     $( "#select-all").click(function (e){
         e.preventDefault();
         $( "td input[type=checkbox]").prop("checked", true);
     });

     $( "#deselect-all").click(function (e){
         e.preventDefault();
         $( "td input[type=checkbox]").prop("checked", false);
     });

     $("#export-csv-local-button").click(function (e){
         let csv = table2csv("results");
         console.log(csv);
         location.href = "data:text/csv;base64," +  window.btoa(csv);
     });

 });
</script>

<div id="dialog-sum-quantity" title="Total"></div>

<fieldset class="add-new-sample">
    <legend><!-- TMPL_VAR add-new-sample-lb --></legend>
    <form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/add-sample/">

        <label for="name"><!-- TMPL_VAR sample-name-lb --></label>
        <input id="name" type="text" name="<!-- TMPL_VAR sample-name -->" />

        <label for="target-person"
               class="input-autocomplete-label">
            <!-- TMPL_VAR person-lb -->
        </label>
        <input id="target-person-id" type="hidden" name="<!-- TMPL_VAR person-id -->" />
        <span class="ui-widget">
            <input type="text" id="target-person"/>
        </span>

        <label for="target-labs"
               class="input-autocomplete-label">
            <!-- TMPL_VAR lab-name-lb -->
        </label>
        <input id="target-labs-id" type="hidden" name="<!-- TMPL_VAR labs-id -->" />
        <span class="ui-widget">
            <input type="text" id="target-labs"/>
        </span>

        <label for="quantity"><!-- TMPL_VAR quantity-lb --></label>
        <input id="quantity" type="text" name="<!-- TMPL_VAR quantity -->" />

        <label for="units"><!-- TMPL_VAR units-lb --></label>
        <input id="units" type="text" name="<!-- TMPL_VAR units -->" />

        <label for="add-sample-compliant-checkbox"><!-- TMPL_VAR compliantp-lb --></label>
        <input type="checkbox"
               id="add-sample-compliant-checkbox"
               name="<!-- TMPL_VAR compliantp-name -->">

        <label for="checkin-date"><!-- TMPL_VAR checkin-date-lb --></label>
        <input id="checkin-date" type="text" name="<!-- TMPL_VAR checkin-date -->" />

        <label for="count"><!-- TMPL_VAR item-count-lb --></label>
        <input id="count" type="text" name="<!-- TMPL_VAR count -->" />

        <label for="textarea-add-sample-description"><!-- TMPL_VAR  description-lb --></label>
        <textarea id ="textarea-add-sample-description" class="add-sample-description"
                  name="<!-- TMPL_VAR description -->"></textarea>

        <label for="textarea-add-sample"><!-- TMPL_VAR  notes-lb --></label>
        <textarea id ="textarea-add-sample" class="add-sample-notes"
                  name="<!-- TMPL_VAR notes -->"></textarea>

        <input id="submit-add" type="submit" />
    </form>
</fieldset>

<fieldset class="search-new-sample">
    <legend><!-- TMPL_VAR search-sample-legend-lb --></legend>
    <form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/search-sample/">
        <label for="sample-name"><!-- TMPL_VAR name-lb --></label>
        <input id="sample-name" type="text" name="<!-- TMPL_VAR sample-search-name -->" />
        <input id="submit-search" type="submit" />
    </form>
</fieldset>

<form method="POST" ACTION="<!-- TMPL_VAR path-prefix -->/others-op-chem-sample/">
    <fieldset class="other-ops-chem-sample">
        <legend><!-- TMPL_VAR  other-operations-lb --></legend>
        <input id="select-all" type="submit"
               name=""
               value="<!-- TMPL_VAR select-all-lb -->"/>
        <input id="deselect-all" type="submit"
               name=""
               value="<!-- TMPL_VAR deselect-all-lb -->"/>
        <input id="submit-mass-del" type="submit"
               name="<!-- TMPL_VAR submit-massive-delete -->"
               value="<!-- TMPL_VAR submit-massive-delete-lb -->"/>
        <fieldset>
            <legend><!-- TMPL_VAR  draw-labels-lb --></legend>
            <label for="label-w">
                <!-- TMPL_VAR width-lb -->
            </label>
            <input id="label-w"
                   name="<!-- TMPL_VAR w-label -->" type="text"
                   value="80.0"/>
            <label for="label-h">
                <!-- TMPL_VAR height-lb -->
            </label>
            <input id="label-h"
                   name="<!-- TMPL_VAR h-label -->" type="text"
                   value="40.0"/>

            <label for="chkbox-use-barcode">
                <!-- TMPL_VAR checkbox-use-barcode-lb -->
            </label>
            <input id="chkbox-use-barcode"
                   name="<!-- TMPL_VAR checkbox-use-barcode -->" type="checkbox" />
            <input id="submit-gen-barcode" type="submit"
                   name="<!-- TMPL_VAR submit-gen-barcode -->"
                   value="<!-- TMPL_VAR submit-gen-barcode-lb -->"/>
        </fieldset>

    </fieldset>

    <!-- TMPL_IF render-results-p -->
    <h3>
        <!-- TMPL_VAR table-res-header -->
        <a id="export-csv-local-button" class="help-button">
            <!-- TMPL_INCLUDE 'download-button.tpl' -->
        </a>
    </h3>

    <table class="sortable sample-list"  id="results">
        <thead>
            <tr>
                <th class="sample-select-id-hd"><!-- TMPL_VAR select-lb --></th>
                <th class="sample-id-hd">ID</th>
                <th class="sample-name-hd"><!-- TMPL_VAR  name-lb --></th>
                <th class="sample-lab-hd"><!-- TMPL_VAR  lab-name-lb --></th>
                <th class="sample-quantity-hd"><!-- TMPL_VAR quantity-lb --></th>
                <th class="sample-units-hd"><!-- TMPL_VAR units-lb --></th>
                <th class="sample-checkin-date-hd"><!-- TMPL_VAR checkin-date-lb --></th>
                <th class="sample-checkout-date-hd"><!-- TMPL_VAR checkout-date-lb --></th>
                <th class="sample-notes-hd"><!-- TMPL_VAR notes-lb --></th>
                <th class="sample-description-hd"><!-- TMPL_VAR description-lb --></th>
                <th class="sample-compliant-hd"><!-- TMPL_VAR compliantp-lb --></th>
                <th class="sample-compliant-hd"><!-- TMPL_VAR person-lb --></th>
                <th class="sample-operations"><!-- TMPL_VAR operations-lb --></th>
            </tr>
        </thead>
        <tbody>
            <!-- TMPL_LOOP data-table -->
            <tr>
                <td class="select-id-id">
                    <input name="<!-- TMPL_VAR checkbox-id -->" type="checkbox" />
                </td>
                <td class="sample-id">
                    <!-- TMPL_VAR sample-id -->
                </td>
                <td class="sample-name">
                    <!-- TMPL_VAR sample-name -->
                </td>
                <td class="sample-lab-name">
                    <!-- TMPL_VAR lab-complete-name -->
                </td>
                <td class="sample-qty">
                    <!-- TMPL_VAR quantity -->
                </td>
                <td class="sample-units">
                    <!-- TMPL_VAR units -->
                </td>
                <td class="checkin-date">
                    <!-- TMPL_VAR checkin-date-decoded -->
                </td>
                <td class="checkout-date">
                    <!-- TMPL_VAR checkout-date-decoded -->
                </td>
                <td class="sample-notes">
                    <!-- TMPL_VAR shortened-notes -->
                </td>
                <td class="sample-description">
                    <!-- TMPL_VAR shortened-description -->
                </td>
                <td class="sample-compliant">
                    <!-- TMPL_IF decoded-compliantp -->
                    <span class="fa fa-check table-marker-yes" aria-hidden="true"></span>
                    <!-- TMPL_ELSE -->
                    <span class="fa fa-close table-marker-no" aria-hidden="true"></span>
                    <!-- /TMPL_IF  -->
                </td>
                <td class="sample-person">
                    <!-- TMPL_VAR person-description -->
                </td>
                <td class="operations">
                    <a href="<!-- TMPL_VAR delete-link -->">
                        <!-- TMPL_INCLUDE 'delete-button.tpl' -->
                    </a>
                    <a href="<!-- TMPL_VAR gen-custom-label-link -->">
                        <!-- TMPL_INCLUDE 'tags-button.tpl' -->
                    </a>
                    <!-- edit sample -->
                    <a href="<!-- TMPL_VAR update-link -->">
                        <!-- TMPL_INCLUDE 'edit-button.tpl' -->
                    </a>
                </td>
            </tr>
            <!-- /TMPL_LOOP  -->
        </tbody>
    </table>
    <!-- /TMPL_IF  --> <!-- if render-results-p ends here-->

</form>
