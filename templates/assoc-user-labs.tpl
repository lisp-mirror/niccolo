<script>
 $(function () {
     const OPENED = -1;
     const CLOSED =  0;

     function setTabLabOpen (id){
         sessionStorage.setItem(id, OPENED);
     }

     function tabLabOpenedP (id){
         let vId = parseInt(id),
             v   = -10;
         if (!isNaN(vId)) {
             v = parseInt(sessionStorage.getItem(vId));
         }

         return (!isNaN(v)) && (v == OPENED);
     }

     function remTabLabOpened (id){
         if (!isNaN(id)){ // valid number
             sessionStorage.setItem(id, CLOSED);
         }
     }

     function row2IdUser (row) {
         let raw = $(row).find(".user-lab-username-id").text().trim();
         return parseInt(raw);
     }


     function findForms(sel) {
         return sel.siblings(".form-assoc");
     }

     $(".user-lab-operations").children().hide();
     $(".user-lab-operations").children("i").show();

     $(".user-lab-operations").children("i")
                              .each(function () {
                                  let par = $(this).parents("tr");
                                  if(tabLabOpenedP(row2IdUser(par))){
                                      findForms($(this)).show();
                                  }
                              });

     $(".toggle-labs").click(function (e){
         let id = row2IdUser($(this).parents("tr"));
         if (!isNaN(id)){ // valid number
             if (tabLabOpenedP(id)){
                 remTabLabOpened(id);
             } else {
                 setTabLabOpen(id);
             }
         }

         findForms($(this)).toggle();
     })
 });
</script>


<table class="sortable assoc-user-lab">
    <thead>
        <tr>
            <th class="user-lab-name-id-hd"><!-- TMPL_VAR user-id-lb --></th>
            <th class="user-lab-name-hd"><!-- TMPL_VAR username-lb --></th>
            <th class="user-lab-operations-hd"><!-- TMPL_VAR operations-lb --></th>
        </tr>
    </thead>
    <tbody>
        <!-- TMPL_LOOP data-table -->
        <tr>
            <td class="user-lab-username-id"><!-- TMPL_VAR user-id-value --></td>
            <td class="user-lab-username"><!-- TMPL_VAR username --></td>
            <td class="user-lab-operations">
              <i class="fa fa-folder-open fa-2x toggle-labs" aria-hidden="true"></i>
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
