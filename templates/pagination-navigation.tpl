
<!-- TMPL_IF prev-start -->
<div class="pagination-minus">
    <form method="GET" ACTION="">
	<input type="hidden"
	       name="<!-- TMPL_VAR pagination-count-name -->"
	       value="<!-- TMPL_VAR pagination-dec -->" />
	<input class="button-pagination" type="submit" value="<" />
    </form>
</div>
<!-- /TMPL_IF -->

<!-- TMPL_IF next-start -->
<div class="pagination-plus">
    <form method="GET" ACTION="">
	<input type="hidden"
	       name="<!-- TMPL_VAR  pagination-count-name -->"
	       value="<!-- TMPL_VAR pagination-inc -->" />
	<input class="button-pagination" type  = "submit" value=">" />
    </form>
</div>
<!-- /TMPL_IF -->
