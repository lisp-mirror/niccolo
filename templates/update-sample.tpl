<script>
 $(function() {
     $( "#checkout-date" ).datepicker({dateFormat : "yy-mm-dd"});
     $( "#expire-date" ).datepicker({dateFormat : "yy-mm-dd"});
     $( "#opening-package-date" ).datepicker({dateFormat : "yy-mm-dd"});
 })

</script>

<form method="GET" ACTION=""/>
<div>
    <label for="update-chemical-id">ID</label>
    <input type="text" id="update-chemical-id" value="<!-- TMPL_VAR id -->"
           disabled="true"/>

    <label for="add-sample-compliant-checkbox"><!-- TMPL_VAR compliantp-lb --></label>
    <input type="checkbox"    id="add-sample-compliant-checkbox"
           name="<!-- TMPL_VAR compliantp-name -->"
    <!-- TMPL_IF decoded-compliantp -->
    checked
    <!-- /TMPL_IF -->
    >

    <label for="quantity"><!-- TMPL_VAR quantity-lb --></label>
    <input id="quantity" type="text"
           name="<!-- TMPL_VAR quantity -->"
           value="<!-- TMPL_VAR quantity-value -->" />

    <label for="units"><!-- TMPL_VAR units-lb --></label>
    <input id="units" type="text"
           name="<!-- TMPL_VAR units -->"
           value="<!-- TMPL_VAR units-value -->" />

    <label for="checkout-date"><!-- TMPL_VAR checkout-date-lb --></label>
    <input id="checkout-date"
           type="text"
           name="<!-- TMPL_VAR checkout-date -->"
           value="<!-- TMPL_VAR checkout-date-value -->" />

    <label for="sample-description-id"><!-- TMPL_VAR  description-lb --></label>
    <textarea id="sample-description-id" class="update-sample-description"
              name="<!-- TMPL_VAR description -->"><!-- TMPL_VAR description-value --></textarea>


    <label for="sample-notes-id"><!-- TMPL_VAR  notes-lb --></label>
    <textarea id="sample-notes-id" class="update-sample-notes"
              name="<!-- TMPL_VAR notes -->"><!-- TMPL_VAR notes-value --></textarea>

    <input type="submit" />
</div>
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->
