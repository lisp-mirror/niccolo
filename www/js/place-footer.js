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

function placeFooter(){
    var hMenu = $( ".left-menu" ).height();
    var hForm = $( "#main-content-wrapper" ).height() +
	$( "#main-content-wrapper" ).position().top;
    var h     =  Math.max(hMenu, hForm);
    if(h <= hMenu){
	$( "#footer" ).css("position", "absolute");
	$( "#footer" ).css("top", hMenu );
    }else{
	$( "#footer" ).css("position", "relative");
	$( "#footer" ).css("top", 0 );
    }

}
