<!-- TMPL_IF display-messages-p -->
<div class="messages">
  <!-- TMPL_IF add-infos-p -->
  <ul class="info-message">
    <!-- TMPL_LOOP infos -->
    <li><!-- TMPL_VAR info --></li>
    <!-- /TMPL_LOOP  -->
  </ul>
  <!-- /TMPL_IF --> 
  <!-- TMPL_IF add-errors-p -->
  <ul class="error-message">
    <!-- TMPL_LOOP errors -->
    <li><!-- TMPL_VAR error --></li>
    <!-- /TMPL_LOOP -->
  </ul>
  <!-- /TMPL_IF --> 
</div>
<!-- /TMPL_IF -->
