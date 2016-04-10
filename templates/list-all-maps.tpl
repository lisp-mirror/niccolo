<!-- TMPL_LOOP all-images -->
<fieldset class="map-image-fieldset">
  <legend><!-- TMPL_VAR map-image-desc --></legend>
  <form action="<!-- TMPL_VAR action -->" method="GET">
    <input class="map-coord-submit" type="image" alt="map"
	   name="<!-- TMPL_VAR coord-name -->"
	   src="<!-- TMPL_VAR map-image-src -->" />
    <input type="hidden"
	   name="<!-- TMPL_VAR   name-map-image-id -->"
	   value="<!-- TMPL_VAR  map-image-id -->" />
    <input type="hidden"
	   name="<!-- TMPL_VAR   map-image-name-building-id -->"
	   value="<!-- TMPL_VAR  map-image-building-id -->" />

  </form>
</fieldset>
<!-- /TMPL_LOOP  -->
