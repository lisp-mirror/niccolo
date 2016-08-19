#! /bin/sh

# niccolo': a chemicals inventory
# Copyright (C) 2016  Universita' degli Studi di Palermo

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


NICCOLO_DIR="$HOME/lisp/niccolo/"

JQUERY_UI_THEME_NAME="cupertino"
TMP_JQUERY_UI_THEMES=`mktemp`
JQUERY_UI_THEMES_URL="https://jqueryui.com/resources/download/jquery-ui-themes-1.12.0.zip"


TMP_JQUERY_UI=`mktemp`
JQUERY_UI_URL="https://jqueryui.com/resources/download/jquery-ui-1.12.0.zip"

SUGAR_URL="https://raw.githubusercontent.com/andrewplummer/Sugar/2.0.0/dist/sugar.js"

#sugar.js

wget $SUGAR_URL -P $NICCOLO_DIR/www/js/

#  jquery and jquery ui

wget $JQUERY_UI_URL -O $TMP_JQUERY_UI

unzip $TMP_JQUERY_UI

JQUERY_UI_DIR=`find . -type d -iname 'jquery-ui*'`

cd $JQUERY_UI_DIR

echo "pwd: $PWD"

cp -v jquery-ui.js $NICCOLO_DIR/www/js/

cp -v external/jquery/jquery.js $NICCOLO_DIR/www/js/

# jquery-ui themes
wget $JQUERY_UI_THEMES_URL -O $TMP_JQUERY_UI_THEMES

unzip $TMP_JQUERY_UI_THEMES

JQUERY_UI_THEMES_DIR=`find . -type d -iname 'jquery-ui-themes*'`

cd $JQUERY_UI_THEMES_DIR

cp *.css $NICCOLO_DIR/www/css/

cp -rv themes/$JQUERY_UI_THEME_NAME/images/ $NICCOLO_DIR/www/css/

cp -v themes/$JQUERY_UI_THEME_NAME/*.css    $NICCOLO_DIR/www/css/
