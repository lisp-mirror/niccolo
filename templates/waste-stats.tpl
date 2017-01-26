<fieldset class="waste-stats">
  <legend>
    <!-- TMPL_VAR legend-group-lb -->

      <a href="<!-- TMPL_VAR spreadsheet-url -->">
	<i class="fa fa-download" aria-hidden="true"></i>
      </a>


  </legend>
  <!-- TMPL_IF cer-group -->
  <table class="waste-stats">
    <caption><!-- TMPL_VAR cer-group-caption-lb --></caption>
    <tr><th><!-- TMPL_VAR code-lb --></th><th><!-- TMPL_VAR weight-lb --></th></tr>
    <!-- TMPL_LOOP cer-group -->
    <tr><td><!-- TMPL_VAR cer-code --></td><td><!-- TMPL_VAR sum-weight --></td></tr>
    <!-- /TMPL_LOOP -->
  </table>

  <table class="waste-stats">
    <caption><!-- TMPL_VAR buildings-group-caption-lb --></caption>
    <tr>
      <th><!-- TMPL_VAR building-description-lb --></th>
      <th><!-- TMPL_VAR weight-lb --></th>
    </tr>
    <!-- TMPL_LOOP buildings-group -->
    <tr>
      <td>
	<b><!-- TMPL_VAR building-name --></b>
	<span>,<!-- TMPL_VAR address-line-1 --></span>
	<span>,<!-- TMPL_VAR city --></span>
	<span>,<!-- TMPL_VAR zipcode --></span>
      </td>
      <td><!-- TMPL_VAR sum-weight --></td>
    </tr>
    <!-- /TMPL_LOOP -->
  </table>

  <table class="waste-stats">
    <caption><!-- TMPL_VAR user-group-caption-lb --></caption>
    <tr><th><!-- TMPL_VAR username-lb --></th><th><!-- TMPL_VAR weight-lb --></th></tr>
    <!-- TMPL_LOOP user-group -->
    <tr><td><!-- TMPL_VAR username --></td><td><!-- TMPL_VAR sum-weight --></td></tr>
    <!-- /TMPL_LOOP -->
  </table>


  <!-- /TMPL_IF -->

  <!-- TMPL_UNLESS cer-group -->
  <!-- TMPL_VAR not-found-lb -->
  <!-- /TMPL_UNLESS -->

</fieldset>
