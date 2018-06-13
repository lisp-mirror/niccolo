/*
  niccolo': a chemicals inventory
  Copyright (C) 2016  Universita' degli Studi di Palermo

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, version 3  of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/** Return a heap-allocated string, remember to free the memory */
char* copy_string (char* orig){
  char* copy = (char*)malloc(strlen(orig) + 1);
  return strcpy(copy, orig);
}

/** Return a heap-allocated string, remember to free the memory */
char* concat_string (char* a, char* b){
  char* res = (char*)malloc(strlen(a) + strlen(b) + 1);
  strcpy(res, a);
  return strcat(res, b);
}

/** Return a heap-allocated string, remember to free the memory */
char* make_mac_auth (char* message, char* secret, char* nonce ){
  char* hash = (char*)malloc(65);
  char* tmp    = concat_string(nonce, message);
  char* decoded = concat_string(tmp, secret);
  sha256_encode(decoded, hash);
  free(tmp);
  free(decoded);
  return hash;
}
