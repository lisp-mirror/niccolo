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
 });
</script>
