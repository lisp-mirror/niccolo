<!-- TMPL_IF prev-start -->
<div>
  <form class="with-attention-scale-anim" id="pagination-minus" method="GET"
	ACTION="<!-- TMPL_VAR pagination-next-page-url -->">
	<input type="hidden"
	       name="<!-- TMPL_VAR pagination-op-name -->"
	       value="<!-- TMPL_VAR pagination-dec -->" />
	<a href="#" onclick="document.forms['pagination-minus'].submit();">
	  <i class="fa fa-caret-square-o-left fa-2x" aria-hidden="true"></i>
	</a>
    </form>
</div>
<!-- /TMPL_IF -->

<!-- TMPL_IF next-start -->
<div>
  <form class="with-attention-scale-anim" id="pagination-plus" method="GET"
	ACTION="<!-- TMPL_VAR pagination-next-page-url -->">
	<input type="hidden"
	       name="<!-- TMPL_VAR  pagination-op-name -->"
	       value="<!-- TMPL_VAR pagination-inc -->" />
	<a href="#" onclick="document.forms['pagination-plus'].submit();">
	  <i class="fa fa-caret-square-o-right fa-2x" aria-hidden="true"></i>
	</a>

    </form>
</div>
<!-- /TMPL_IF -->

<div id="pagination-no-of-items">
  <form class="with-attention-scale-anim" id="pagination-more-items" method="GET"
	ACTION="<!-- TMPL_VAR pagination-next-page-url -->">
    <input type="hidden"
	   name="<!-- TMPL_VAR  pagination-count-name -->"
	   value="<!-- TMPL_VAR pagination-more-items -->" />
    <a href="#" onclick="document.forms['pagination-more-items'].submit();">
      <i class="fa fa-plus-square" aria-hidden="true"></i>
    </a>
  </form>


  <form class="with-attention-scale-anim" id="pagination-less-items" method="GET"
	ACTION="<!-- TMPL_VAR pagination-next-page-url -->">
    <input type="hidden"
	   name="<!-- TMPL_VAR  pagination-count-name -->"
	   value="<!-- TMPL_VAR pagination-less-items -->" />
    <a href="#"
       onclick="document.forms['pagination-less-items'].submit();">
      <i class="fa fa-minus-square" aria-hidden="true"></i>
    </a>
  </form>
</div>
