<script>

 $(function() {
     $.ajax({
	 url:    "<!-- TMPL_VAR message-count-service-url -->",
	 method: "GET",
	 data: {  }
     }).success(function( data ) {
         let res       = JSON.parse(data),
             currCount = res.<!-- TMPL_VAR message-count-key -->;
         if (currCount > 0){
             $("#message-notification-count").text(currCount);
             $("#message-notification-link").show();
         } else {
             $("#message-notification-link").hide();
         }
     }).error(function( data ) {});
 });
</script>
