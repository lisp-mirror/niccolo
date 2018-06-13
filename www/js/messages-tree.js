/*
   niccolo': a chemicals inventory
   Copyright (C) 2016  Universita' degli Studi di Palermo

   This  program is  free  software: you  can  redistribute it  and/or
   modify it  under the  terms of  the GNU  General Public  License as
   published  by  the  Free  Software Foundation,  version  3  of  the
   License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

$(function() {
    function buildMessageTable (data) {
	var res = "<table class='user-messages'>";

	function addChildren(child){
	    var urlIdx     = 1;
	    var subjectIdx = 3;
	    var timeIdx    = 5;

            res+= "<tr>"                                                               +
                  "<span class='fa fa-reply fa-rotate-180' aria-hidden='true'></span>" +
                  "<td class='user-message-reply-row' colspan='8'>"                    +
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
	    placeFooter();
	});
    })
});
