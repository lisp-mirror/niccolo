<style>


</style>
<script>
    $(function() {
	var sep="-";
	// hide all except root
	$("#tree-container div").not("#1").hide();

	$(document).on("click","a[name]",function(){
	    var to=$(this).attr("name");
	    $("#" + to).show();
	    $("#tree-container div").not("#" + to).hide();
	    var count=to.lastIndexOf(sep);
	    $("#tree-container div").not("#" + to).hide();
	    $(document).find(".back").remove();
	    var breadcrumbLink=to;
	    if(count < 0){
		//$("#" + to).append('<a class="back" name="' + to + '">back</a>');
	    }else{
		//$("#" + to).append('<a class="back" name="' + to.substring(0,count) + '">back</a>');
		breadcrumbLink = to.substring(0,count);
	    }

	    var breadcrumbText=	$(this).parent().find("span").text();
	    if (breadcrumbText){
		var breadcrumbNode=
		    '<a class="breadcrumb-link" name="' +
		    breadcrumbLink                      +
		    '">' + breadcrumbText + "("+ $(this).text() +")" +
		    '</a>';
		$("#breadcrumb").append(breadcrumbNode)
		$("#breadcrumb").append(" &gt; ");
	    }
	});
    });
</script>

<p id="breadcrumb">

</p>

<div id="tree-container">
  <div class="node" id="1">
    <span class="description">
      Potentially explosive?
    </span>
    <a class="decision" name="1-1">yes</a>
    <a class="decision" name="1-2">no</a>
  </div>
  <div class="node" id="1-1">
    <span class="description">
      Potentially Explosive Chemical Storage
    </span>
    <a class="decision" name="2">Second Level Segregation</a>
  </div>
  <div class="node" id="1-2">
    <span class="description">
      Flammable?
    </span>
    <a class="decision" name="1-2-1">yes</a>
    <a class="decision" name="1-2-2">no</a>
  </div>
  <div class="node" id="1-2-1">
    <span class="description">
      Flammable Storage
    </span>
    <a class="decision" name="2">Second Level Segregation</a>
  </div>
  <div class="node" id="1-2-2">
    <span class="description">
      corrosive?
    </span>
    <a class="decision" name="1-2-2-2">yes</a>
    <a class="decision" name="1-2-2-1">no</a>
  </div>
  <div class="node" id="1-2-2-1">
    <span class="description">
      General Storage
    </span>
    <a class="decision" name="2">Second Level Segregation</a>
  </div>
  <div class="node" id="1-2-2-2">
    <span class="description">
      Mineral acid?
    </span>
    <a class="decision" name="1-2-2-2-1">yes</a>
    <a class="decision" name="1-2-2-2-2">no</a>
  </div>
  <div class="node" id="1-2-2-2-1">
    <span class="description">
      Mineral Acid Storage
    </span>
    <a class="decision" name="2">Second Level Segregation</a>
  </div>
  <div class="node" id="1-2-2-2-2">
    <span class="description">
      Caustic?
    </span>
    <a class="decision" name="1-2-2-2-2-1">yes</a>
    <a class="decision" name="1-2-2-2-2-2">no</a>
  </div>
  <div class="node" id="1-2-2-2-2-1">
    <span class="description">
      Caustic Storage
    </span>
    <a class="decision" name="2">Second Level Segregation</a>
  </div>
  <div class="node" id="1-2-2-2-2-2">
    <span class="description">
      General Storage
    </span>
    <a class="decision" name="2">Second Level Segregation</a>
  </div>

  <!--- second level segregations -->


  <div class="node" id="2">
    <span class="description">
      Oxidizer?
    </span>
    <a class="decision" name="2-1">yes</a>
    <a class="decision" name="2-2">no</a>
  </div>


  <!-- <div class="node" id="1-2-1-1"> -->
  <!--   <span class="description"> -->
  <!--     Oxidizer? -->
  <!--   </span> -->
  <!--   <a class="decision" name="2-1">yes</a> -->
  <!--   <a class="decision" name="2-2">no</a> -->
  <!-- </div> -->


  <!-- <div class="node" id="1-2-2-1-1"> -->
  <!--   <span class="description"> -->
  <!--     Oxidizer? -->
  <!--   </span> -->
  <!--   <a class="decision" name="2-1">yes</a> -->
  <!--   <a class="decision" name="2-2">no</a> -->
  <!-- </div> -->


  <!-- <div class="node" id="1-2-2-1-1-1"> -->
  <!--   <span class="description"> -->
  <!--     Oxidizer? -->
  <!--   </span> -->
  <!--   <a class="decision" name="2-1">yes</a> -->
  <!--   <a class="decision" name="2-2">no</a> -->
  <!-- </div> -->


  <!-- <div class="node" id="1-2-2-2-2-1-1"> -->
  <!--   <span class="description"> -->
  <!--     Oxidizer? -->
  <!--   </span> -->
  <!--   <a class="decision" name="2-1">yes</a> -->
  <!--   <a class="decision" name="2-2">no</a> -->
  <!-- </div> -->


  <!-- <div class="node" id="1-2-2-2-2-2-1"> -->
  <!--   <span class="description"> -->
  <!--     Oxidizer? -->
  <!--   </span> -->
  <!--   <a class="decision" name="2-1">yes</a> -->
  <!--   <a class="decision" name="2-2">no</a> -->
  <!-- </div> -->


  <div class="node" id="2-1">
    <span class="description">
      OX (do not store with flammables)
    </span>
  </div>

  <div class="node" id="2-2">
    <span class="description">
      Organic?
    </span>
    <a class="decision" name="2-2-1">yes</a>
    <a class="decision" name="2-2-2">no</a>
  </div>

  <div class="node" id="2-2-2">
    <span class="description">
      Water reactive electrophile (e. g. Lewis Acid)?
    </span>
    <a class="decision" name="2-2-2-1">yes</a>
    <a class="decision" name="2-2-2-2">no</a>
  </div>

  <div class="node" id="2-2-2-1">
    <span class="description">
      WR INORG ELEC
    </span>
  </div>

  <div class="node" id="2-2-2-2">
    <span class="description">
      Water reactive nucleophile?
    </span>
    <a class="decision" name="2-2-2-2-1">yes</a>
    <a class="decision" name="2-2-2-2-2">no</a>
  </div>

  <div class="node" id="2-2-2-2-1">
    <span class="description">
      WR NUC
    </span>
  </div>

  <div class="node" id="2-2-2-2-2">
    <span class="description">
      WNR NUC
    </span>
  </div>

  <div class="node" id="2-2-1">
    <span class="description">
      Neutral reactive?
    </span>
    <a class="decision" name="2-2-1-1">yes</a>
    <a class="decision" name="2-2-1-2">no</a>
  </div>

  <div class="node" id="2-2-1-1">
    <span class="description">
      NEUT or WNR ELEC
    </span>
  </div>

  <div class="node" id="2-2-1-2">
    <span class="description">
      Nucleophile?
    </span>
    <a class="decision" name="2-2-1-2-1">yes</a>
    <a class="decision" name="2-2-1-2-2">no</a>
  </div>

  <div class="node" id="2-2-1-2-1">
    <span class="description">
      Water reactive nucleophile?
    </span>
    <a class="decision" name="2-2-1-2-1-1">yes</a>
    <a class="decision" name="2-2-1-2-1-2">no</a>
  </div>

  <div class="node" id="2-2-1-2-1-1">
    <span class="description">
      WR NUC
    </span>
  </div>

  <div class="node" id="2-2-1-2-1-2">
    <span class="description">
      WNR NUC
    </span>
  </div>


  <div class="node" id="2-2-1-2-2">
    <span class="description">
      Water reactive nucleophile?
    </span>
    <a class="decision" name="2-2-1-2-2-1">yes</a>
    <a class="decision" name="2-2-1-2-2-2">no</a>
  </div>

  <div class="node" id="2-2-1-2-2-1">
    <span class="description">
      WR ORG ELEC
    </span>
  </div>

  <div class="node" id="2-2-1-2-2-2">
    <span class="description">
      WNR ELEC/NEUT
    </span>
  </div>



</div>

<!-- TMPL_INCLUDE 'back-button.tpl' -->

<div class="biblio-ref">
  <div class="authors">
    John J. M. Wiener and Cheryl A. Grice
  </div>
  <div class="title">
    Practical Segregation of Incompatible Reagents in the Organic
    Chemistry Laboratory
  </div>
  <div class="publication">
    Organic Process Research & Development 2009,13,1395–1400
  </div>
  <div class="biblio-id">
    <a href="http://pubs.acs.org/doi/abs/10.1021/op900094d">
      DOI: 10.1021/op900094d
    </a>
  </div>
</div>
