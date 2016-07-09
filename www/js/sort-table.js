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
    $(".sortable").find("th").attr('title', 'Click to sort');

    var order = true;

    function getParentTable(el){
	return el.parent().parent().parent();
    }


    $(".sortable th").click(function (e) {
	order = ! order;
	var txt   = $(this).text();
	var allTH = $(this).parent().children().toArray();
	var pos   = allTH.findIndex(function (cell){
	    return $(cell).text() == txt;
	});
	var theTable         = $(this).parent().parent().parent().find("tbody tr");
	var sortedTable      = theTable.get().sort(function(a, b) {
	    var keyChildren1 = $($(a).children().get(pos)).text();
	    var keyChildren2 = $($(b).children().get(pos)).text();
	    var res = order ? keyChildren1 > keyChildren2 ? 1 : -1:
	                      keyChildren1 < keyChildren2 ? 1 : -1;
	    return res;
	});
	getParentTable($(this)).find("tbody").append(sortedTable);
    });

});
