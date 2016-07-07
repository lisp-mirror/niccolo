<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset='utf-8'" />
  <title><!-- TMPL_VAR title --></title>
  <link rel="icon" type="image/vnd.microsoft.icon" href="<!-- TMPL_VAR path-prefix -->/images/favicon.ico" />
  <link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR css-file -->" />
  <link rel="stylesheet" href="<!-- TMPL_VAR jquery-ui-css -->" />
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
  });
</script>
