<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<form method="POST" ACTION="<!-- TMPL_VAR path-prefix -->/add-chemical/"
      enctype="multipart/form-data">
  <label for="name-text"><!-- TMPL_VAR name-lb --></label>
  <input id="name-text" type="text" name="<!-- TMPL_VAR name -->" />
  <label for="cid-text">Pubchem CID</label>
  <input id="cid-text" type="text" name="<!-- TMPL_VAR pubchem-cid -->" />
  <label for="msds-file"><!-- TMPL_VAR msds-file-lb --></label>
  <input id="msds-file"   type="file" name="<!-- TMPL_VAR msds-pdf -->" />
  <label for="struct-file"><!-- TMPL_VAR struct-file-lb --></label>
  <input id="struct-file" type="file" name="<!-- TMPL_VAR struct-data -->" />
  <input type="submit" />
</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->

<table class="sortable chemical-list">
  <thead>
    <tr>
      <th class="chemical-id-hd">ID</th>
      <th class="chemical-name-hd"><!-- TMPL_VAR name-lb --></th>
      <th class="chemical-data-sheet-hd"><!-- TMPL_VAR data-sheet-lb --></th>
      <th class="chemical-struct-file-hd"><!-- TMPL_VAR struct-file-lb --></th>
      <th class="chemical-haz-diamond-hd"><!-- TMPL_VAR  haz-diamond-lb --></th>
      <th class="chemical-operations"><!-- TMPL_VAR operations-lb --></th>
    </tr>
  </thead>
  <tbody>
    <!-- TMPL_LOOP data-table -->
    <tr>
      <td class="chemical-id">
        <!-- TMPL_VAR id -->
      </td>
      <td class="chemical-name">
        <!-- TMPL_VAR name -->
      </td>
      <td class="chemical-data-sheet">
        <!-- TMPL_IF has-msds -->
        <a href="<!-- TMPL_VAR msds-pdf-link -->">
          <div class="msds-pdf-button">&nbsp;</div>
        </a>
        <!-- /TMPL_IF -->
      </td>
      <td class="chemical-struct-file">
          <!-- TMPL_IF has-struct-file -->
          <a href="<!-- TMPL_VAR struct-file-link -->">
              <div class="struct-file-button">&nbsp;</div>
          </a>
          <!-- /TMPL_IF -->
      </td>
      <td class="chemp-haz-diamond">
          <div><img src="<!-- TMPL_VAR haz-diamond-url -->" /></div>
          <table class="haz-diamond-toggle">
              <tr>
                  <td>
                      Haza.
                      <a href="<!-- TMPL_VAR  toggle-haz-diamond-haz-link -->"
                         class="haz-diam-haz with-attention-scale-anim">
                          &#x25C6;
                      </a>
                  </td>
                  <td>
                      Flam.
                      <a href="<!-- TMPL_VAR toggle-haz-diamond-fire-link -->"
                         class="haz-diam-fire with-attention-scale-anim">
                          &#x25C6;
                      </a>

                  </td>
                  <td>
                      Corr.
                      <a href="<!-- TMPL_VAR toggle-haz-diamond-corrosive-link -->"
                         class="haz-diam-corrosive with-attention-scale-anim">
                          &#x25C6;
                      </a>

                  </td>
                  <td>
                      Reac.
                      <a href="<!-- TMPL_VAR toggle-haz-diamond-reactive-link -->"
                         class="haz-diam-reactive with-attention-scale-anim">
                          &#x25C6;
                      </a>
                  </td>
              </tr>
          </table>
      </td>
      <td class="chemical-op-link">
          <a href="<!-- TMPL_VAR delete-link -->">
              <div class="delete-button">&nbsp;</div>
          </a>
          <a href="<!-- TMPL_VAR assoc-haz-link -->">
              <div class="ghs-haz-button">&nbsp;</div>
          </a>
          <a href="<!-- TMPL_VAR assoc-prec-link -->">
              <div class="ghs-prec-button">&nbsp;</div>
          </a>
          <a href="<!-- TMPL_VAR assoc-sec-fq-link -->">
              <div class="assoc-security-fq">
                  <i  class="fa fa-cloud-download fa-2x"
                      aria-hidden="true">
                  </i>
              </div>
          </a>

        <script>
          $(function() {
              // Shorthand for $( document ).ready()
              $( "#fieldset-subst-msds<!-- TMPL_VAR id -->" ).dialog({
                  show:  { effect: false },
                  title: "Substitute MSDS",
                  autoOpen: false
              });

              $( "#button-subst-msds<!-- TMPL_VAR id -->").click(function(){
                  $( "#fieldset-subst-msds<!-- TMPL_VAR id -->" ).dialog("open");
              });
          });
        </script>

        <script>
         $(function() {
             // Shorthand for $( document ).ready()
             $( "#fieldset-subst-struct<!-- TMPL_VAR id -->" ).dialog({
                 show:  { effect: false },
                 title: "Substitute structure file",
                 autoOpen: false
             });

             $( "#button-subst-struct<!-- TMPL_VAR id -->").click(function(){
                 $( "#fieldset-subst-struct<!-- TMPL_VAR id -->" ).dialog("open");
             });
         });
        </script>

        <!-- msds -->
        <a href="#"
           id="button-subst-msds<!-- TMPL_VAR id -->">
          <div class="add-msds-pdf-button">&nbsp;</div>
        </a>

        <div
           id="fieldset-subst-msds<!-- TMPL_VAR id -->">
            <form method="POST"
                  ACTION="<!-- TMPL_VAR path-prefix -->/subst-msds/<!-- TMPL_VAR id -->"
                  enctype="multipart/form-data">
                <input id="subst-msds-file" type="file" name="<!-- TMPL_VAR msds-pdf -->" />
            <input type="submit" />
          </form>
        </div>

        <!-- structure file -->
        <a href="#"
           id="button-subst-struct<!-- TMPL_VAR id -->">
            <div class="add-struct-file-button">&nbsp;</div>
        </a>

        <div
            id="fieldset-subst-struct<!-- TMPL_VAR id -->">
            <form method="POST"
                  ACTION="<!-- TMPL_VAR path-prefix -->/subst-struct-file/<!-- TMPL_VAR id -->"
                  enctype="multipart/form-data">
                <input id="subst-struct-file" type="file" name="<!-- TMPL_VAR struct-data -->" />
                <input type="submit" />
            </form>
        </div>


        <!-- edit chemical -->
        <a href="<!-- TMPL_VAR update-chemical-link -->">
          <div class="edit-button">&nbsp;</div>
        </a>

      </td>
    </tr>
    <!-- /TMPL_LOOP  -->
  </tbody>
</table>

<!-- TMPL_INCLUDE 'pagination-navigation.tpl' -->
