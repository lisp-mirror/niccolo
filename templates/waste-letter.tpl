<script>
    // Shorthand for $( document ).ready()
    $(function() {
	var availableCer = <!-- TMPL_VAR json-cer -->;
	var availableCerId   = <!-- TMPL_VAR json-cer-id -->;
	$( "#target-cer" ).autocomplete({
	    source: availableCer ,
	    select: function( event, ui ) {
		var idx = $.inArray(ui.item.label, availableCer);
		$("#target-cer-id").val(availableCerId[idx]);
	    }
	});
    	var availableBuilding = <!-- TMPL_VAR json-building -->;
	var availableBuildingId   = <!-- TMPL_VAR json-building-id -->;
	$( "#target-building" ).autocomplete({
	    source: availableBuilding ,
	    select: function( event, ui ) {
		var idx = $.inArray(ui.item.label, availableBuilding);
		$("#target-building-id").val(availableBuildingId[idx]);
	    }
	});

	var keypressCb = function (e){
	    var txt=$(this).val();
	    $(this).parent().find("option").css('display','block');
	    $(this).parent().find("option").filter(
		function () {
		    return $(this).text().indexOf(txt) < 0 ? true : false;
		}).css('display','none')

	}

	$("#waste-form-adr-filter").keyup(keypressCb);

	$("option").click(function (){
	    $("#adr-selected").children().remove();
	    var sel=$(this).parent().find("option").filter(":selected").toArray();
	    sel.each(function (a) {
		$("#adr-selected").append("<li>" + $(a).text() + "</li>");
	    });
	});

    });
</script>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/write-waste-letter/">
  <label for="name-text"><!-- TMPL_VAR name-lb --></label>
  <input id="name-text" type="text" name="<!-- TMPL_VAR name -->" />
  <input id="target-cer-id" type="hidden" name="<!-- TMPL_VAR cer-id -->" />

  <label for="target-cer">CER</label>
  <span class="ui-widget">
    <input type="text" id="target-cer"/>
  </span>

  <input id="target-building-id" type="hidden" name="<!-- TMPL_VAR building-id -->" />

  <label for="target-building"><!-- TMPL_VAR building-lb --></label>
  <span class="ui-widget">
    <input type="text" id="target-building"/>
  </span>

  <label for="lab-no"><!-- TMPL_VAR laboratory-lb --></label>
  <input type="text" id="lab-no" name="<!-- TMPL_VAR lab-num -->" />

  <label for="weight"><!-- TMPL_VAR weight-lb --></label>
  <input type="text" id="weight" name="<!-- TMPL_VAR weight -->" />


  <fieldset id="adr-list">
    <legend>ADR</legend>
    <input title="Type filter criteria" id="waste-form-adr-filter" type="text" />
    <select id="waste-form-adr-select" name="select-adr" multiple="yes" size="10">
      <!-- TMPL_LOOP adr-list -->
      <option value="<!-- TMPL_VAR adr-id -->"><!-- TMPL_VAR adr-uncode --> (<!-- TMPL_VAR adr-code-class -->) - <!-- TMPL_VAR adr-expl --></option>
      <!-- /TMPL_LOOP -->
    </select>
    <ul id="adr-selected"></ul>
  </fieldset>

  <div>
    <div><label for="textarea-note-waste"><!-- TMPL_VAR description-lb --></label></div>
    <textarea id="textarea-note-waste" name="<!-- TMPL_VAR description -->"></textarea>
    <input type="submit" />
  </div>

</form>
