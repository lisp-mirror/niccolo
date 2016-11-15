<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<script src="<!-- TMPL_VAR path-prefix -->/js/federated-query.js"></script>


<script>
    // Shorthand for $( document ).ready()
    $(function() {
	function deassocHaz(codes){
	    if (! (codes === null)){
		codes.forEach(function (code) {
		    let url     = "<!-- TMPL_VAR lookup-haz-code-url -->",
			keyCode = "<!-- TMPL_VAR haz-code-assoc-name -->";
		    $.ajax({url:    url,
			    method: "GET",
			    data:   {[keyCode] : code}
			   }).success(function( data ) {
			       let hid     = JSON.parse(data),
				   chemId  = "<!-- TMPL_VAR value-compound-id -->",
				   url     = "<!-- TMPL_VAR path-prefix -->" +
				             "/remove-haz-code-from-chem/"   +
				   hid + "/" + chemId;

			       $.ajax(
				   {url:    url,
				    method: "GET"})
				   .success(function( data ) {})
			           .error(function( data ) {});
			   });
		});
	    }
	}

	function deassocPrec(codes){
	    if (! (codes === null)){
		codes.forEach(function (code) {
		    let url     = "<!-- TMPL_VAR lookup-prec-code-url -->",
			keyCode = "<!-- TMPL_VAR prec-code-assoc-name  -->";
		    $.ajax({url:    url,
			    method: "GET",
			    data:   {[keyCode] : code}
			   }).success(function( data ) {
			       let pid     = JSON.parse(data),
				   chemId  = "<!-- TMPL_VAR value-compound-id -->",
				   url     = "<!-- TMPL_VAR path-prefix -->" +
				             "/remove-prec-code-from-chem/"   +
				   pid + "/" + chemId;

			       $.ajax(
				   {url:    url,
				    method: "GET"})
				   .success(function( data ) {})
			           .error(function( data ) {});
			   });
		});
	    }
	}

	function assocHaz(codes){
	    if (! (codes === null)){
		codes.forEach(function (code) {
		    let url     = "<!-- TMPL_VAR lookup-haz-code-url -->",
			keyCode = "<!-- TMPL_VAR haz-code-assoc-name -->";
		    $.ajax({url:    url,
			    method: "GET",
			    data:   {[keyCode] : code}
			   }).success(function( data ) {
			       let url     = "<!-- TMPL_VAR path-prefix -->/add-assoc-chem-haz/",
				   hid     = JSON.parse(data),
				   hkey    = "<!-- TMPL_VAR haz-code-id -->",
				   chemId  = "<!-- TMPL_VAR value-compound-id -->",
				   chemKey = "<!-- TMPL_VAR haz-compound-id -->";
			       $.ajax(
				   {url:    url,
				    method: "GET",
				    data: { [hkey]: hid,
				            [chemKey] : chemId}})
				   .success(function( data ) {});
			   });
		});
	    }
	}

	function assocPrec(codes){
	    if (! (codes === null)){
		codes.forEach(function (code) {
		    let url     = "<!-- TMPL_VAR lookup-prec-code-url -->",
			keyCode = "<!-- TMPL_VAR prec-code-assoc-name -->";
		    $.ajax({url:    url,
			    method: "GET",
			    data:   {[keyCode] : code}
			   }).success(function( data ) {
			       let url     = "<!-- TMPL_VAR path-prefix -->/add-assoc-chem-prec/",
				   pid     = JSON.parse(data),
				   pkey    = "<!-- TMPL_VAR prec-code-id -->",
				   chemId  = "<!-- TMPL_VAR value-compound-id -->",
				   chemKey = "<!-- TMPL_VAR prec-compound-id -->";
			       $.ajax(
				   {url:    url,
				    method: "GET",
				    data: { [pkey]: pid,
				            [chemKey] : chemId}})
				   .success(function( data ) {});
			   });
		});
	    }
	}

	var hazCodesFetched  = new Array();

	var precCodesFetched = new Array();

	var normaArraytoStringClsr = function(a){
	    let fn = function(){
		let res ="";
		if (!(a === null)){
		    res = a.toString();
		}
		return res;
	    };
	    return fn;
	};

	var tableTemplate =
	    "<tr>"                        +
	    "<td>{{host}}</td>"           +
	    "<td>{{name}}</td>"           +
	    "<td>{{haz}}</td>"            +
	    "<td>{{prec}}</td>"           +
	    "<td>"                        +
	    "<i class=\"positive-button " +
	    "add-ajax-button\""           +
            "aria-hidden=\"true\">"       +
	    "</i>"                        +
	    "<i class=\"negative-button " +
	    "remove-ajax-button\""        +
            "aria-hidden=\"true\">"       +
	    "</i>"                        +
	    "</td>"                       +
	    "</tr>";

	function fetchHazard(){
	    $("#fq-res-container").show(1000);
	    let key        = $("#compound-name").text(),
		urlKey     = "<!-- TMPL_VAR fq-query-key-param -->",
		startUrl   = "<!-- TMPL_VAR fq-start-url -->",
		resultsUrl = "<!-- TMPL_VAR fq-results-url -->",
		successFn  = function (data){
		    try{
			var info = JSON.parse(data);
			info.forEach(function (a) {
			    let vTpl  = {};
			    vTpl.host = a.host;
			    vTpl.name = a.name;
			    vTpl.haz  = normaArraytoStringClsr(a.haz);
			    vTpl.prec = normaArraytoStringClsr(a.prec);
			    $( "#fq-results tbody" ).append(Mustache.render(tableTemplate,vTpl))
			    hazCodesFetched.push(a.haz);
			    precCodesFetched.push(a.prec);
			});

			function refreshPosButton(node){
			    $(node).addClass("positive-button");
			    $(node).siblings().removeClass("activate-button");
			}

			function refreshNegButton(node){
			    $(node).addClass("negative-button");
			    $(node).siblings().removeClass("activate-button");
			}

			$( ".add-ajax-button" ).click(function(e){
			    var index = $( ".add-ajax-button" ).index( this );
			    refreshPosButton(this);
			    $(this).addClass("fa-refresh");
			    $(this).addClass("fa-spin");
			    $(this).addClass("fa-fw");
			    assocHaz(hazCodesFetched[index]);
			    assocPrec(precCodesFetched[index]);
			    $(this).removeClass("fa-refresh");
			    $(this).removeClass("fa-spin");
			    $(this).removeClass("fa-fw");
			    $(this).addClass("activate-button");
			});

			$( ".remove-ajax-button" ).click(function(e){
			    var index = $( ".remove-ajax-button" ).index( this );
			    refreshNegButton(this);
			    $(this).addClass("fa-refresh");
			    $(this).addClass("fa-spin");
			    $(this).addClass("fa-fw");
			    deassocHaz(hazCodesFetched[index]);
			    deassocPrec(precCodesFetched[index]);
			    $(this).removeClass("fa-refresh");
			    $(this).removeClass("fa-spin");
			    $(this).removeClass("fa-fw");
			    $(this).addClass("activate-button");
			});



		    }catch (a){
			alert("Error parsing json data" + a);
		    };
		    placeFooter();

		},
		errorFn  = function(a) { alert("Error fetching data");};

	    federatedQuery(key, urlKey, startUrl, resultsUrl, successFn, errorFn);
	};

	fetchHazard();

    });
</script>

<div>
    <h2 id="compound-name"><!-- TMPL_VAR compound-name --></h2>
</div>

<div id="fq-res-container" style="display: none">

  <table class="chemp-list" id="fq-results">
    <thead>
      <tr>
	<th class="chem-origin-hd"><!-- TMPL_VAR origin-lb -->  </th>
	<th class="chem-name-hd">  <!-- TMPL_VAR  name-lb -->   </th>
	<th class="chem-haz-hd">   <!-- TMPL_VAR hazard-codes-lb --></th>
	<th class="chem-haz-hd">   <!-- TMPL_VAR prec-codes-lb --></th>
        <th class="chem-haz-op">   <!-- TMPL_VAR operations-lb --></th>
      </tr>
    </thead>
    <tbody>
    </tbody>
  </table>

  <div class="ajax-loader-federated-query">
    <img src="<!-- TMPL_VAR path-prefix -->/images/ajax-loader.gif" />
  </div>

</div>

<!-- TMPL_INCLUDE 'back-button.tpl' -->
