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
    $( "#sum-selected" ).click(function(e){
	e.preventDefault();
	var selectedRows = $.makeArray($( ".sortable" ).find("tbody").find("tr"));
	var sumProduct   = function (a, b){
	    var qty =$(b).find(".sum").text().trim();
	    if(isNaN(parseFloat(qty))){
		return a;
	    } else{
		return a + parseFloat(qty);
	    }
	};
	var sum          = selectedRows.reduce(sumProduct,0);
	$( "#dialog-sum" ).children("p").remove();
	$( "#dialog-sum" ).append("<p>Quantity: <b>" + sum + "</b></p>");
	$( "#dialog-sum" ).dialog("open");

    })

    $( "#dialog-sum" ).dialog({
	show:  { effect: false },
	autoOpen: false
    });

});
