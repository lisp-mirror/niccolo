<!-- TMPL_IF messages -->

<script>

// Shorthand for $( document ).ready()
$(function() {
    function buildMessageTable (data) {
	var res = "<table>";

	function addChildren(child){
	    var urlIdx     = 1;
	    var subjectIdx = 3;
	    var timeIdx    = 5;

            res+= "<tr>"                                                               +
                  "<span class='fa fa-reply fa-rotate-180' aria-hidden='true'></span>" +
                  "<td colspan='8'>"                                                   +
	          "<a class='open-response-link' href='"+  child[urlIdx]  + "'>"       +
	          child[subjectIdx] + child[timeIdx]                                   +
	          "</a>"                                                               +
		  "</td>"                                                              +
		  "</tr>";
	}

	res+=
	    "<thead>"                                                        +
	    "<tr>"                                                           +
            "<th class='id-hd'>ID</th>"                                      +
	    "<th class='sent-time-hd'><!-- TMPL_VAR sent-time-lb --></th>"   +
	    "<th class='sender-name-hd'><!-- TMPL_VAR sender-lb --></th>"    +
	    "<th class='rcpt-name-hd'><!-- TMPL_VAR rcpt-lb --></th>"        +
	    "<th class='subject-hd'><!-- TMPL_VAR subject-lb --></th>"       +
	    "<th class='message-hd'><!-- TMPL_VAR message-lb --></th>"       +
	    "</tr>"                                                          +
	    "</thead>"                                                       +
	    "<tbody>"                                                        +
	    "<tr>"                                                           +
	    "<td class='sender-name'>" + data.mid + "</td>"                  +
	    "<td class='sent-time'>"   + data.decodedSentTime + "</td>"      +
	    "<td class='sender-name'>" + data.senderUsername + "</td>"       +
	    "<td class='rcpt-name'>"   + data.rcptUsername +     "</td>"     +
	    "<td class='subject'>"     + data.subject + "</td>"              +
	    "<td class='message'>"     + data.text + "</td>";

	var children = data.children;

	if (! children == null){
	    children.forEach(addChildren);
	}

	res+= "</tbody>"                                                     +
	    "</table>";
	return $(res);
    }


    $( ".open-response-link" ).click(function(e){
	var that = this;
	var href=$(this).attr("href");
	e.preventDefault();
	e.stopPropagation();
	$.ajax({
	    url: href
	}).done(function( data ) {

	    var info=JSON.parse(data);
	    var table = buildMessageTable(info);
	    $(that).parent().children('table').remove();
	    $(that).parent().append(table);

	});
    })
});
</script>

<h3> <!-- TMPL_VAR expiration-messages-hd-lb --></h3>

<!-- TMPL_LOOP messages -->
<table class="expiration-messages">
  <thead>
    <tr>
      <th class="id-hd">ID</th>
      <th class="id-product-hd"><!-- TMPL_VAR product-id-lb --></th>
      <th class="sent-time-hd"><!-- TMPL_VAR sent-time-lb --></th>
      <th class="sender-name-hd"><!-- TMPL_VAR sender-lb --></th>
      <th class="rcpt-name-hd"><!-- TMPL_VAR rcpt-lb --></th>
      <th class="subject-hd"><!-- TMPL_VAR subject-lb --></th>
      <th class="message-hd"><!-- TMPL_VAR message-lb --></th>
      <th class="operations-lb"><!-- TMPL_VAR operations-lb --></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class="sender-name"><!-- TMPL_VAR msg-id --></td>
      <td class="id-product"><!-- TMPL_VAR chemp-id-string --></td>
      <td class="sent-time"><!-- TMPL_VAR decoded-sent-time --></td>
      <td class="sender-name"><!-- TMPL_VAR sender-username --></td>
      <td class="rcpt-name"><!-- TMPL_VAR rcpt-username --></td>
      <td class="subject"><!-- TMPL_VAR subject --></td>
      <td class="message"><!-- TMPL_VAR text --></td>
      <td class="operations">
	<a href="<!-- TMPL_VAR delete-link -->">
	  <div class="delete-button">
	    &nbsp;
	  </div>
	</a>
      </td>
    </tr>
    <!-- TMPL_LOOP children -->
    <tr>
      <td class="user-message-reply-row" colspan="8">
	<span class="fa fa-reply fa-rotate-180" aria-hidden="true"></span>
	<a class="open-response-link" href=" <!-- TMPL_VAR url -->">
	  <!-- TMPL_VAR time --> <!-- TMPL_VAR subject -->
	</a>
      </td>
    </tr>
    <!-- /TMPL_LOOP  -->
  </tbody>
</table>
<!-- /TMPL_LOOP  -->

<!-- /TMPL_IF -->
