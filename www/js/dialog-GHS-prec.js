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

// Shorthand for $( document ).ready()
$(function() {
    $( "#dialog-GHS-prec" ).dialog({
	show:  { effect: false },
	title: "GHS precaution statement",
	autoOpen: false
    });



    $( ".GHS-prec-link" ).click(function(e){
	var href=$(this).attr("href");
	e.preventDefault();
	$.ajax({
	    url: href
	}).done(function( data ) {
	    var info=JSON.parse(data);
	    $( "#dialog-GHS-prec" ).children("div").remove();
	    info.forEach(function(a){
		$( "#dialog-GHS-prec" ).append("<div>" + a.desc + "<div>");
	    });

	});
	$( "#dialog-GHS-prec" ).dialog("open");
    })

});
