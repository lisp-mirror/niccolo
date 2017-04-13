<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title><!-- TMPL_VAR title --></title>
  <link rel="icon" type="image/vnd.microsoft.icon" href="<!-- TMPL_VAR path-prefix -->/images/favicon.ico" />
  <link rel="stylesheet" href="<!-- TMPL_VAR jquery-ui-css -->" />
  <link rel="stylesheet" href="<!-- TMPL_VAR anim-css -->" />
  <link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR css-file -->" />
  <script src="<!-- TMPL_VAR jquery -->"></script>
  <script src="<!-- TMPL_VAR jquery-ui -->"></script>
  <script src="<!-- TMPL_VAR sugar -->"></script>
  <script src="<!-- TMPL_VAR mustache -->"></script>
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

      function setClassesUi (){
	  $("legend").addClass("ui-widget-header ui-state-default ui-corner-all");
	  $("th").addClass("ui-widget-header ui-state-active");
	  $("fieldset").addClass("ui-corner-all");
	  $(".info-message").addClass("ui-state-highlight ui-corner-all");
	  $(".error-message").addClass("ui-state-error ui-corner-all");
      }


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
      $("select").not("[multiple]").selectmenu();
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

      setClassesUi();

      $(".with-attention-scale-anim").mouseover(function() {
	  $(this).removeClass("anim-scale-down-2x");
	  $(this).addClass("anim-scale-up-2x");
      });

      $(".with-attention-scale-anim").mouseout(function() {
	  $(this).removeClass("anim-scale-up-2x");
	  $(this).addClass("anim-scale-down-2x");
      });

      $(".with-menu-item-anim").mouseover(function() {
	  $(this).removeClass("anim-menu-attention-out");
	  $(this).addClass("anim-menu-attention-get");
      });

      $(".with-menu-item-anim").mouseout(function() {
	  $(this).removeClass("anim-menu-attention-get");
	  $(this).addClass("anim-menu-attention-out");
      });


  });
</script>
