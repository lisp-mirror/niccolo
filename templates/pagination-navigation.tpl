<script src="<!-- TMPL_VAR path-prefix -->/js/get-get.js"></script>

<script>
 // Shorthand for $( document ).ready()
 $(function() {

     if(getParameterByName("<!-- TMPL_VAR  pagination-count-name -->")){
         window.scroll(0, $(document).height());
     }

     $(".pagination-operation-form").on("submit", function(event) {
         let action = $(this).attr('action'),
             paginationOpName     = "<!-- TMPL_VAR pagination-op-name -->",
             paginationCountName  = "<!-- TMPL_VAR pagination-count-name -->",
             paginationOpVal      = $(this).find("input[name='" + paginationOpName +"']" ),
             paginationCountVal   = $(this).find("input[name='" + paginationCountName +"']"),
             query                = getQueryString(),
             reOp                 = new RegExp(paginationOpName + "=" + "[^&]+&*",'g'),
             reCount              = new RegExp(paginationCountName + "=" + "[^&]+&*",'g'),
             loc                  = action + "?",
             locModifiedP         = false;

         if(paginationOpVal && $(paginationOpVal).val() ){
             loc += paginationOpName    + "=" + $(paginationOpVal).val();
             locModifiedP = true;
         }

         if(paginationCountVal && $(paginationCountVal).val()){
             loc += paginationCountName + "=" + $(paginationCountVal).val();
             locModifiedP = true;
         }

         query = query.replace(reOp, "").replace(reCount, "");

         event.preventDefault();

         if (getQueryString() != null){
             if (locModifiedP){
                 window.location.href = loc + "&" + query;
             } else {
                 window.location.href = loc + query;
             }

         }
     });


 });
</script>


<!-- TMPL_IF prev-start -->
<div>
    <form class="pagination-operation-form" id="pagination-minus" method="GET"
	  ACTION="<!-- TMPL_VAR pagination-next-page-url -->">
	<input type="hidden"
	       name="<!-- TMPL_VAR pagination-op-name -->"
	       value="<!-- TMPL_VAR pagination-dec -->" />
        <input type="submit" value="&#x2B05;" />
    </form>
</div>
<!-- /TMPL_IF -->

<!-- TMPL_IF next-start -->
<div>
    <form class="pagination-operation-form" id="pagination-plus" method="GET"
	  ACTION="<!-- TMPL_VAR pagination-next-page-url -->">
	<input type="hidden"
	       name="<!-- TMPL_VAR  pagination-op-name -->"
	       value="<!-- TMPL_VAR pagination-inc -->" />
        <input type="submit" value="&#x2B95;" />
    </form>
</div>
<!-- /TMPL_IF -->

<div id="pagination-no-of-items">
    <form class="pagination-operation-form" id="pagination-more-items" method="GET"
	  ACTION="<!-- TMPL_VAR pagination-next-page-url -->">

        <input type="hidden"
	       name="<!-- TMPL_VAR  pagination-count-name -->"
	       value="<!-- TMPL_VAR pagination-more-items -->" />
        <input type="submit" value="&#x2795;" />
    </form>


    <form class="pagination-operation-form" id="pagination-less-items" method="GET"
	  ACTION="<!-- TMPL_VAR pagination-next-page-url -->">
        <input type="hidden"
	       name="<!-- TMPL_VAR  pagination-count-name -->"
	       value="<!-- TMPL_VAR pagination-less-items -->" />
        <input type="submit" value="&#x2796;" />
    </form>
</div>
