<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title><!-- TMPL_VAR title --></title>
  <link rel="icon" type="image/vnd.microsoft.icon" href="<!-- TMPL_VAR path-prefix -->/images/favicon.ico" />
  <link rel="stylesheet" href="<!-- TMPL_VAR jquery-ui-css -->" />
  <link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR css-file -->" />
  <script src="<!-- TMPL_VAR jquery -->"></script>
  <script src="<!-- TMPL_VAR jquery-ui -->"></script>
  <script src="<!-- TMPL_VAR sugar -->"></script>
  <link rel="stylesheet" href="<!-- TMPL_VAR path-prefix -->/css/font-awesome-4.6.3/css/font-awesome.min.css">
</head>
<body>
<script>
  $(function() {
      $( document ).tooltip({
	  position: {
	      my: "left bottom",
              at: "left top"
	  }
      });
      $("button").button();
      $("input:submit").button();
      $("input:button").button();
      $("select").not('#waste-form-adr-select').selectmenu();
      $("#accordion-menu").accordion({
	  header     : "li.menu-level-1",
	  heightStyle: "content",
	  collapsible: true,
	  autoHeight: true,
          active: false

      }).css('width', '200pt');
  });
</script>
