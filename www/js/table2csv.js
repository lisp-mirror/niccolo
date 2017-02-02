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

var lineTerminator = "\r\n";

function escapeCSVField (f){
    return "\"" +  f.replace(/\"/g, "\"") + "\"";
}

function buildCSVLine (rawDOM, fieldFn, cellTag = "td") {
    let res = new Array();
    $(rawDOM).find(cellTag).toArray().forEach(function(f) {
	let field = fieldFn(escapeCSVField($(f).text().trim()));
	res.push(field);
    });

    return res;
}

function table2csv (tableId, fieldFn = (a) => a){
    let res     = "",
	records = $("#" + tableId).find("tr").toArray();

    records.forEach(function(a) {
	let line = buildCSVLine(a, fieldFn, "th");
	if (line.length > 0) {
	    res+= line.join(",") + lineTerminator;
	}
    });


    records.forEach(function(a) {
	let line = buildCSVLine(a, fieldFn, "td");
	if (line.length > 0) {
	    res+= line.join(",") + lineTerminator;
	}
    });

    return res;
}
