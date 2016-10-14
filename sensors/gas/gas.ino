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

#include <SPI.h>

#include <util.h>
#include <EthernetClient.h>
#include <EthernetServer.h>
#include <Dns.h>
#include <EthernetUdp.h>
#include <Dhcp.h>
#include <Ethernet.h>

#include "sha256.h"
#include "http.h"

#include "mq135.h"

// Always change the value of the following variable,
// the new value should match with the one configured on the server.
char secret_key[] = "asdfghjklqwe";

byte mac[] = {
  0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6
};

IPAddress ip(192, 168, 1, 178);

EthernetServer server(80);

#define CALIBRATION_MAX_COUNT    10

#define DELAY_CALIBRATION     240000 // 4 minute

#define STARTING_DELAY        360000

#define MAX_RESISTANCE_VALUE  9999.0

float calibration_average = 0.0;

float calibration_std_dev = 0.0;

float calibration_values[CALIBRATION_MAX_COUNT] = {0.0};

void setup() {

  Serial.begin(9600);

  Serial.println(F("STARTING"));
  delay(STARTING_DELAY);

  Serial.println(F("STARTING CALIBRATION"));

  for (int i = 0; i < CALIBRATION_MAX_COUNT; i++){
    float r = getResistance();
    calibration_values[i] = r;
    calibration_average += r;
    //Serial.println(r);
    delay(DELAY_CALIBRATION);
  }

  calibration_average /= CALIBRATION_MAX_COUNT;

  for (int i = 0; i < CALIBRATION_MAX_COUNT; i++){
    calibration_std_dev += pow((calibration_values[i] - calibration_average),2);
    //Serial.println(calibration_values[i]);
  }

  calibration_std_dev = sqrt( (1.0 / (CALIBRATION_MAX_COUNT - 1)) * calibration_std_dev);

  //Serial.println(calibration_std_dev,2);
  //Serial.println(calibration_average,2);

  Ethernet.begin(mac, ip);
  server.begin();
  Serial.print(F("server is at "));
  Serial.println(Ethernet.localIP());

}

// heap allocated
char* read_line (EthernetClient client){
    char* res = (char*)malloc(128);
    memset((void*)res, '\0', 128);
    char c = client.read();
    int ct = 0;
    while (ct < 126   &&
	   c  >= 0    &&
	   c  != '\n' &&
	   ct >= 0){
      res[ct] = c;
      c = client.read();
      ct++;
    }

    if (ct > 1){
      res[ct - 1] = '\0';
    }else{
      res[0] = '\0';
    }

    return res;
}

char read_line_is_empty (char* l){
  return strcmp(l, "") == 0;
}

void send_response (EthernetClient client, char* nonce){
 float res = getResistance();
  if (res > 0 && res <= MAX_RESISTANCE_VALUE){
    String body = "{\"g\":$g,\"a\":$a,\"s\":$s}";
    char str_gas[6] = "";
    itoa(floor(res), str_gas,10);
    body.replace("$g", str_gas);
    char str_avg[6] = "";
    itoa(floor(calibration_average), str_avg, 10);
    body.replace("$a", str_avg);
    char str_stddev[6] = "";
    itoa(floor(calibration_std_dev), str_stddev, 10);
    body.replace("$s", str_stddev);

    char* resp_calc_mac_req = make_mac_auth((char*)body.c_str(),
					    secret_key,
					    nonce);
    build_ok_response((char*)body.c_str(), resp_calc_mac_req);
    client.print(response);
    //Serial.println(body);
    free(resp_calc_mac_req);
  } else { // an overflow occurred
    build_error_response();
    client.print(response);

  }
}


void loop() {
  // listen for incoming clients
  EthernetClient client = server.available();
  if (client) {
    while (client.connected()) {
      if (client.available()) {
	// heap;
	char* command        = read_line(client);
	// stack
	char* path           = http_path(command);
	// heap
	char*  mac_line   = NULL;
	char*  nonce_line = NULL;

	if(path != NULL){
	  // heap
	  char* req_line   = NULL;
	  while (!read_line_is_empty((req_line = read_line(client)))){
	    // heap
	    char* copy_req   = copy_string(req_line);
	    // heap
	    char* copy_req2  = copy_string(req_line);
	    // no more need for raw request
	    free(req_line);
	    // stack
	    char* mac_req   = http_mac_header(copy_req);
	    char* nonce_req = http_nonce_header(copy_req2);
	    if(mac_req != NULL){ // MAC header found
	      // Serial.print(F("mac: "));
	      // Serial.println(mac_req);
	      mac_line    = copy_string(mac_req);
	    }else if(nonce_req != NULL){ // nonce header found
	      // Serial.print(F("nonce: "));
	      // Serial.println(nonce_req);
	      nonce_line    = copy_string(nonce_req);
	    }

	    free(copy_req);
	    free(copy_req2);

	  }
	  free(req_line);
	}
	Serial.println(F("end req"));

	if (mac_line && nonce_line) {
	  // heap
	  char* calculated_mac_req = make_mac_auth(path, secret_key, nonce_line);
	  if (strcasecmp(calculated_mac_req, mac_line) == 0){ // authenticated
	    Serial.print(F("OK "));
	    // Serial.println(calculated_mac_req);
	    send_response(client, nonce_line);
	  }else{
	    build_not_found_response();
	    client.print(response);
	  }
	  free(calculated_mac_req);
	}else{
	  Serial.println(F("NO"));
	  build_not_found_response();
	  client.print(response);
	}

	free(mac_line);
	free(nonce_line);
	free(command);
	delay(1);
	client.stop();
      }
    }
  }
}
