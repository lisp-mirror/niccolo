<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/qrcode.js"></script>

<script>
    function cleanDialog(){
  	$( "#dialog" ).children("br").remove();
	$( "#dialog" ).children("p").remove();
	$( "#dialog" ).children("a").remove();
	$( "#dialog" ).children("img").remove();
    }

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

	$( "#dialog" ).dialog({
	    show:  { effect: false },
	    title: "Information",
	    autoOpen: false,
	    width:'auto'
	});


	$( ".building-link" ).click(function(e){
	    var href=$(this).attr("href");
	    e.preventDefault();
	    $.ajax({
		url: href
	    }).done(function( data ) {

		var info=JSON.parse(data);
		// address
		// link
		// name
		cleanDialog();
		$( "#dialog" ).append("<p>" + info.name + "</p>");
		$( "#dialog" ).append("<p>" + info.address + "</p>");
		var link =$("<a>Website</a>");
		link.attr('href',info.link);
		$( "#dialog" ).append(link);

	    });
	    $( "#dialog" ).dialog("open");
	})


    });

function drawQRcode(text, typeNumber, errorCorrectLevel) {
    cleanDialog();
    $( "#dialog" ).append(createQRcode(text, typeNumber, errorCorrectLevel));
    $( "#dialog" ).append("<br />");
    $( "#dialog" ).append("<a id='save-qr-code'>Save image</a>");
    $( "#dialog" ).dialog("open");
    $( "#save-qr-code" ).on("click",function(e){
	var sib = $(this).siblings("img");
	window.location.href = sib.attr('src').replace('image/gif', 'image/octet-stream')});
};

function createQRcode(text, typeNumber, errorCorrectLevel) {
    var qr = qrcode(typeNumber || 8, errorCorrectLevel || 'M');
    qr.addData(text);
    qr.make();
    return qr.createImgTag(8, 8);

};

</script>

<div id="dialog" title="">

</div>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/add-storage/">
  <label for="name-text"><!-- TMPL_VAR name-lb --></label>
  <input id="name-text" type="text" name="<!-- TMPL_VAR name -->" />
  <label for="target-building"
         class="input-autocomplete-label">
      <!-- TMPL_VAR building-lb -->
  </label>
  <input id="target-building-id" type="hidden" name="<!-- TMPL_VAR building-id -->" />
  <span class="ui-widget">
    <input type="text" id="target-building"/>
  </span>
  <label for="floor-text"><!-- TMPL_VAR floor-lb --></label>
  <input id="floor-text" type="text" name="<!-- TMPL_VAR floor -->" />
  <input type="submit" />
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->

<table class="sortable storage-list">
  <thead>
    <tr>
      <th class="storage-id-hd">ID</th>
      <th class="storage-map-link-hd"><!-- TMPL_VAR map-lb --></th>
      <th class="storage-name-hd"><!-- TMPL_VAR name-lb --></th>
      <th class="storage-building-name-hd"><!-- TMPL_VAR building-lb --></th>
      <th class="storage-floor-hd"><!-- TMPL_VAR floor-lb --></th>
      <th class="storage-operations"><!-- TMPL_VAR operations-lb --></th>
    </tr>
  </thead>
  <tbody>
  <!-- TMPL_LOOP data-table -->
  <tr>
    <td class="storage-id">
      <!-- TMPL_VAR storage-id -->
    </td>
    <td class="storage-link">
      <!-- TMPL_IF has-storage-link -->
      <a href="<!-- TMPL_VAR storage-link -->" target="_blank" >
	<!-- TMPL_INCLUDE 'map-marker-button.tpl' -->
      </a>
      <!-- /TMPL_IF -->
    </td>
    <td class="storage-name">
      <!-- TMPL_VAR name -->
    </td>
    <td class="storage-building-name">
      <a class="building-link" href="<!-- TMPL_VAR building-link -->">
	<!-- TMPL_VAR building-name -->
      </a>
    </td>
    <td class="storage-floor">
      <!-- TMPL_VAR floor -->
    </td>
    <td class="storage-delete-link">
      <a href="<!-- TMPL_VAR delete-link -->">
	<!-- TMPL_INCLUDE 'delete-button.tpl' -->
      </a>
      <a href="<!-- TMPL_VAR location-add-link -->">
	<!-- TMPL_INCLUDE 'add-map-button.tpl' -->
      </a>
      <a href="<!-- TMPL_VAR update-storage-link -->">
	<!-- TMPL_INCLUDE 'edit-button.tpl' -->
      </a>
      <a>
	<i class="fa fa-qrcode fa-2x table-button" aria-hidden="true"
	   onclick="drawQRcode('<!-- TMPL_VAR qr-string -->')">
	</i>
      </a>
    </td>
  </tr>
  <!-- /TMPL_LOOP  -->
  </tbody>
</table>

<!-- TMPL_INCLUDE 'pagination-navigation.tpl' -->
