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
    $( "#dialog-GHS-haz" ).dialog({
	show:  { effect: false },
	title: "GHS hazard statement",
	autoOpen: false
    });



    $( ".GHS-haz-link" ).click(function(e){
	var href=$(this).attr("href");
	e.preventDefault();
	$.ajax({
	    url: href
	}).done(function( data ) {
	    var info=JSON.parse(data);
	    $( "#dialog-GHS-haz" ).children("ul").remove();
	    $( "#dialog-GHS-haz" ).append("<ul></ul>");
	    info.each(function(a){
		var img="<img  src=\"" + a.pictogramUri +"\">";
		$( "#dialog-GHS-haz" ).children("ul").append("<li>" +
							     img         +
							     a.desc
							     + "</li>");
	    });

	});
	$( "#dialog-GHS-haz" ).dialog("open");
    })

});
