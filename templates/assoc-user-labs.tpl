<script>
 $(function () {
     $(".user-lab-operations").children().hide();
     $(".user-lab-operations").children("i").show();

     $(".toggle-labs").click(function (e){
	 $(this).siblings(".form-assoc").toggle();
     })
 });
</script>


<table class="sortable assoc-user-lab">
    <thead>
	<tr>
	    <th class="user-lab-name-hd"><!-- TMPL_VAR username-lb --></th>
	    <th class="user-lab-operations-hd"><!-- TMPL_VAR operations-lb --></th>
	</tr>
    </thead>
    <tbody>
	<!-- TMPL_LOOP data-table -->
	<tr>
	    <td class="user-lab-username"><!-- TMPL_VAR username --></td>
	    <td class="user-lab-operations">
	      <i class="fa fa-file-text fa-2x toggle-labs" aria-hidden="true"></i>
	      <form class ="form-assoc"
		    method="GET" ACTION="<!-- TMPL_VAR path-prefix -->/assoc-user-lab/">
		    <input type="hidden"
			   name="<!-- TMPL_VAR  user-id -->"
			   value="<!-- TMPL_VAR user-id-value -->" />
		    <!-- TMPL_LOOP list-labs -->
		    <input type="checkbox"
			   id="<!-- TMPL_VAR lab-id-checkbox -->"
			   name="<!-- TMPL_VAR lab-id-name -->"
			   value="<!-- TMPL_VAR lab-id-checkbox -->"
		    <!-- TMPL_IF checked -->
		    checked
		    <!-- /TMPL_IF -->
		    />
		    <label for="<!-- TMPL_VAR lab-id-checkbox -->">
			<!-- TMPL_VAR lab-name -->
		    </label>
		    <!-- /TMPL_LOOP  -->
		    <input type="submit" />
		</form>
	    </td>
	</tr>
	<!-- /TMPL_LOOP  --> <!-- data table -->
    </tbody>
</table>

<!-- TMPL_INCLUDE 'pagination-navigation.tpl' -->


<!-- TMPL_INCLUDE 'back-button.tpl' -->
