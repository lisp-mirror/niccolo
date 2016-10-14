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

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "utils.h"

#define HTTP_FIELDS_DELIM   " "

#define HTTP_MAC_HEADER     "MAC:"

#define HTTP_NONCE_HEADER   "NONCE:"

#define MIME_TYPE_HEADER    "Content-Type: text/plain"

#define LENGTH_HEADER       "Content-Length:"

#define HTTP_PROT           "HTTP/1.0"

#define HTTP_OK             200

#define HTTP_NOT_FOUND      404

#define HTTP_ERROR          500

#define RESPONSE_MAX_LENGTH 244

#define MAX_BODY_LENGTH     100

#define VALID_PATH          "/"

static const PROGMEM char resp_ok_fmt[] = "%s %i OK\r\n%s\r\n%s %i\r\n%s %s\r\n\r\n%s";

static const PROGMEM char resp_notfound_fmt[] = "%s %i Not Found\r\n%s %i\r\n\r\n";

static const PROGMEM char resp_error_fmt[] = "%s %i internal error\r\n%s %i\r\n\r\n";

char response[RESPONSE_MAX_LENGTH]= {0};

char* http_path (char* line){
  strtok(line, HTTP_FIELDS_DELIM);
  char* path = strtok(NULL, HTTP_FIELDS_DELIM);
  if (path != NULL && strcmp(path, VALID_PATH) == 0){
    return path;
  }else{
    return NULL;
  }
}

char* http_mac_header (char* line){
  char* header = strtok(line, HTTP_FIELDS_DELIM);
  char* MAC    = strtok(NULL, HTTP_FIELDS_DELIM);
  if( strcasecmp(header, HTTP_MAC_HEADER) == 0 ){ // note: ignoring case
    return MAC;
  } else {
    return NULL;
  }

}

char* http_nonce_header (char* line){
  char* header = strtok(line, HTTP_FIELDS_DELIM);
  char* nonce  = strtok(NULL, HTTP_FIELDS_DELIM);
  if( strcasecmp(header, HTTP_NONCE_HEADER) == 0 ){ // note: ignoring case
    return nonce;
  } else {
    return NULL;
  }

}

void build_ok_response (char* body, char* mac){

  if(strlen(body) >= MAX_BODY_LENGTH){
    body[MAX_BODY_LENGTH] = '\0';
  }

  snprintf_P(response,
	     RESPONSE_MAX_LENGTH,
	     resp_ok_fmt,
	     HTTP_PROT, HTTP_OK,
	     MIME_TYPE_HEADER,
	     LENGTH_HEADER,
	     strlen(body) < MAX_BODY_LENGTH ? strlen(body) : MAX_BODY_LENGTH,
	     HTTP_MAC_HEADER, mac,
	     body);

}

void build_not_found_response (){
  snprintf_P(response,
	     RESPONSE_MAX_LENGTH,
	     (const char*)resp_notfound_fmt,
	     HTTP_PROT, HTTP_NOT_FOUND,
	     LENGTH_HEADER,0);
}

void build_error_response (){
  snprintf_P(response,
	     RESPONSE_MAX_LENGTH,
	     (const char*)resp_error_fmt,
	     HTTP_PROT, HTTP_ERROR,
	     LENGTH_HEADER,0);
}
