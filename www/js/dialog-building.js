/*
   niccolo': a chemicals inventory
   Copyright (C) 2016  Universita' degli Studi di Palermo

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, version 3 of the License.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

// Shorthand for $( document ).ready()
$(function() {
    $( "#dialog-building" ).dialog({
	show:  { effect: false },
	title: "Information",
	autoOpen: false
    });



    $( ".building-link" ).click(function(e){
	var href=$(this).attr("href");
	e.preventDefault();
	$.ajax({
	    url: href
	}).done(function( data ) {
	    var info=JSON.parse(data);
	    // address
	    // link
	    // name
	    $( "#dialog-building" ).children("p").remove();
	    $( "#dialog-building" ).children("a").remove();
	    $( "#dialog-building" ).append("<p>" + info.name + "</p>");
	    $( "#dialog-building" ).append("<p>" + info.address + "</p>");
	    var link =$("<a>Website</a>");
	    link.attr('href',info.link);
	    $( "#dialog-building" ).append(link);

	});
	$( "#dialog-building" ).dialog("open");
    })

});
