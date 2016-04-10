<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<script>
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
	    autoOpen: false
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
		$( "#dialog" ).children("p").remove();
		$( "#dialog" ).children("a").remove();
		$( "#dialog" ).append("<p>" + info.name + "</p>");
		$( "#dialog" ).append("<p>" + info.address + "</p>");
		var link =$("<a>Website</a>");
		link.attr('href',info.link);
		$( "#dialog" ).append(link);

	    });
	    $( "#dialog" ).dialog("open");
	})

    });
</script>

<div id="dialog" title="">

</div>

<form method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/add-storage/">
  <label for="name-text">Name</label>
  <input id="name-text" type="text" name="<!-- TMPL_VAR name -->" />
  <label for="target-building">Building</label>
  <input id="target-building-id" type="hidden" name="<!-- TMPL_VAR building-id -->" />
  <span class="ui-widget">
    <input type="text" id="target-building"/>
  </span>
  <label for="floor-text">Floor</label>
  <input id="floor-text" type="text" name="<!-- TMPL_VAR floor -->" />
  <input type="submit" />
</form>


<table class="sortable storage-list">
  <thead>
    <tr>
      <th class="storage-id-hd">ID</th>
      <th class="storage-map-link-hd">Map</th>
      <th class="storage-name-hd">Name</th>
      <th class="storage-building-name-hd">Building</th>
      <th class="storage-floor-hd">Floor</th>
      <th class="storage-operations">Operations</th>
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
	<div class="location-button">
	  &nbsp;
	</div>
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
	<div class="delete-button">
	  &nbsp;
	</div>
      </a>
      <a href="<!-- TMPL_VAR location-add-link -->">
	<div class="location-add-button">
	  &nbsp;
	</div>
      </a>
      <a href="<!-- TMPL_VAR update-storage-link -->">
	<div class="edit-button">&nbsp;</div>
      </a>
    </td>
  </tr>
  <!-- /TMPL_LOOP  -->
  </tbody>
</table>
