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
    $( "#sum-selected" ).click(function(e){
	e.preventDefault();
	var selectedRows = $.makeArray($( ".sortable" ).find("tbody").find("tr"));
	var reMult       =  new RegExp("^[mM]");
	var sumProduct   = function (a, b){
	    var selectedP = $(b).find("input:checkbox").is(":checked");
	    if (selectedP){
		var qty  =$(b).find(".chemp-qty").text().trim();
		var units=$(b).find(".chemp-units").text().trim();
		var mult = reMult.test(units) ? 1e-3 : 1.0;
		return a + parseFloat(qty) * mult;
	    }else{
		return a;
	    }
	};
	var sum          = selectedRows.reduce(sumProduct,0);
	$( "#dialog-sum-quantity" ).children("p").remove();
	$( "#dialog-sum-quantity" ).append("<p>Quantity: <b>" + sum + "</b></p>");
	$( "#dialog-sum-quantity" ).dialog("open");

    })

    $( "#dialog-sum-quantity" ).dialog({
	show:  { effect: false },
	autoOpen: false
    });

});
