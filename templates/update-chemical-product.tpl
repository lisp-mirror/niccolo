<script>
 $(function() {
     $( "#validity-date" ).datepicker({dateFormat : "yy-mm-dd"});
     $( "#expire-date" ).datepicker({dateFormat : "yy-mm-dd"});
     $( "#opening-package-date" ).datepicker({dateFormat : "yy-mm-dd"});

     var availablePerson = <!-- TMPL_VAR json-person -->;
     var availableId     = <!-- TMPL_VAR json-person-id -->;
     $( "#target-person" ).autocomplete({
         source: availablePerson ,
         select: function( event, ui ) {
             var idx = $.inArray(ui.item.label, availablePerson);
             $("#target-person-id").val(availableId[idx]);
         }
     });

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

    <!-- ----------------------- carcinogenic starts here ----------------- -->
    <!-- TMPL_IF carcinogenicp -->

    <p> <!-- TMPL_VAR carcinogenic-warning --> </p>

    <label for="target-labs"
           class="input-autocomplete-label">
        <!-- TMPL_VAR lab-name-lb -->
    </label>
    <input id="target-labs-id" type="hidden" name="<!-- TMPL_VAR labs-id -->" />
    <span class="ui-widget">
        <input type="text" id="target-labs"/>
    </span>


    <label for="target-person"
           class="input-autocomplete-label">
        <!-- TMPL_VAR person-id-lb -->
    </label>
    <input id="target-person-id" type="hidden" name="<!-- TMPL_VAR person-id -->" />
    <span class="ui-widget">
        <input type="text" id="target-person"/>
    </span>

    <label for="worker-codes"><!-- TMPL_VAR worker-code-lb --></label>
    <input id="worker-codes" type="text"
	   name="<!-- TMPL_VAR worker-code -->" />

    <label for="work-type"><!-- TMPL_VAR work-type-lb --></label>
    <input id="work-type" type="text"
	   name="<!-- TMPL_VAR work-type -->" />

    <label for="work-types-codes"><!-- TMPL_VAR work-type-code-lb --></label>
    <input id="work-types" name="<!-- TMPL_VAR work-type-code -->">

    <label for="work-methods"><!-- TMPL_VAR work-methods-lb --></label>
    <input id="work-methods" type="text"
	   name="<!-- TMPL_VAR work-methods -->" />

    <label for="exposition-time"><!-- TMPL_VAR exposition-time-lb --></label>
    <input id="exposition-time" type="text"
	   name="<!-- TMPL_VAR exposition-time -->" />

    <!-- /TMPL_IF -->
    <!-- ----------------------- carcinogenic ends here ----------------- -->
    <input type="submit" />
  </div>
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->
