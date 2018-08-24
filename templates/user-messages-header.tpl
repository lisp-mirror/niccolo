<script src="<!-- TMPL_VAR path-prefix -->/js/get-get.js"></script>

<form method="GET" action="">
    <label for="search-query"><!-- TMPL_VAR query-lb --></label>
    <input id="login-name" type="text" name="<!-- TMPL_VAR query-name -->"
           value="">
    <input id="login-submit" type="submit">
</form>

<script>
 // Shorthand for $( document ).ready()
 $(function() {

     var replaceFn = function (idx) {
         $(this).contents().each(function(n){
             if (this.nodeType === Node.TEXT_NODE){
                 let text = $(this).text();
                 text = text.replace(/<!-- TMPL_VAR query-re -->/,
                                     '<span class="text-highlighted">$&</span>');
                 $(this).replaceWith(text);
             }
         });
     };

     $("td").each(replaceFn);

     // keeps query string when deleting message

     function keepQueryLinkClick (selectorString) {
         $(selectorString).on("click", function(event) {
             let action = $(this).attr('href'),
                 loc                  = action,
                 query                = getQueryString();
             event.preventDefault();

             if (query != null){
                 loc += "?" + query;
             }

             window.location.href = loc;
         });
     }

     keepQueryLinkClick(".delete-message-link");

 });
</script>
