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

      let activeAccordionIndexKey = 'activeAccordionIndex';

      function setAccordionActiveIndex (v){
	  sessionStorage.setItem(activeAccordionIndexKey, v);
      }

      function getAccordionActiveIndex (){
	  let parsed = parseInt(sessionStorage.getItem(activeAccordionIndexKey));
	  if (!isNaN(sessionStorage.getItem(activeAccordionIndexKey))){
	      return parsed;
	  } else {
	      return null;
	  }
      }


      $("button").button();
      $("input:submit").button();
      $("input:button").button();
      $("select").not('#waste-form-adr-select').selectmenu();
      $("#accordion-menu").accordion({
	  activate   : function( event, ui ) {
	      var index = jQuery("#accordion-menu").find(".ui-accordion-header-active").index() / 2;
	      setAccordionActiveIndex (index);
	  },
	  header     : "li.menu-level-1",
	  heightStyle: "content",
	  collapsible: true,
	  autoHeight : true,
          active     : getAccordionActiveIndex() != null ? getAccordionActiveIndex() : false

      }).css('width', '200pt');



  });
</script>
