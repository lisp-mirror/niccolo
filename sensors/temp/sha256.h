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

#include <inttypes.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include <avr/pgmspace.h>


#define LITTLE_ENDIAN

#define PADDING_VEC_SIZE 56

const PROGMEM uint32_t k[64] = {
   0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
   0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
   0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
   0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
   0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
   0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
   0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
   0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
};

const PROGMEM uint32_t padding_vec[PADDING_VEC_SIZE] = {
  0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

// not used but could be useful in others projects ;-)

uint32_t rotate_left (uint32_t in, int amount) {
  uint32_t mask     = 0xffffffff  << (32 - amount);
  uint32_t l  = (in & mask) >>  (32 -amount) ;
  uint32_t r  = in <<  amount;
  return   l | r;
}

uint32_t rotate_right (uint32_t in, int amount) {
  uint32_t l  = in  <<  (32 -amount) ;
  uint32_t r  = in >>  amount;
  return   l | r;
}

// return the actual number of byte written
int string_to_big_endian_word (char* string, uint32_t* res, int offset){
  unsigned int ct = 0;

  for (ct = 0; ct + offset < strlen(string) && ct < 4; ct++){
    char* a = (char*)res;

#ifdef LITTLE_ENDIAN
    a[3 - ct] = string[ ct + offset ];
#endif

#ifndef LITTLE_ENDIAN
    a[ct] = string[ ct + offset ];
#endif

  }

  return ct;
}

void pad_length (char* to_encode, uint32_t* w) {
  uint64_t len  = strlen(to_encode) * 8; // length in bits
  uint32_t len1 = (len & 0xffffffff00000000) >> 32;
  uint32_t len2 = (len & 0x00000000ffffffff);

  w[14] = len1;
  w[15] = len2;
}

void extend_chunk (uint32_t* w){
  for (int ct = 16; ct < 64; ct++){
    uint32_t s0 = rotate_right(w[ ct - 15 ],  7)  ^
                  rotate_right(w[ ct - 15 ], 18)  ^
                  w[ ct - 15 ] >>  3;
    uint32_t s1 = rotate_right(w[ ct - 2  ], 17)  ^
                  rotate_right(w[ ct - 2  ], 19)  ^
                  w[ ct - 2  ] >> 10;
    w[ct]       = w[ ct - 16] + s0 + w[ ct - 7] + s1;
  }
}

char* sha256_encode (char* to_encode, char* results){
  uint32_t starting_hash[8] = {
    0x6a09e667,
    0xbb67ae85,
    0x3c6ef372,
    0xa54ff53a,
    0x510e527f,
    0x9b05688c,
    0x1f83d9ab,
    0x5be0cd19
  };

  int num_octects_padding = (64 - strlen(to_encode) % 64);

  int written_bytes_so_far = strlen(to_encode);

  int padded_bytes_so_far  = 0;

  int n_chunks  = strlen(to_encode) < 56 ? 64 : strlen(to_encode) + num_octects_padding;

  int stop_fill = 0;

  for (int i = 0 ; i < n_chunks; i += 64){
    uint32_t chunk[16] = {0x0};
    for (int j = 0; j < 16; j++){
      if(!stop_fill){
	int written_bytes = string_to_big_endian_word(to_encode, &chunk[j], i + j * 4);
	if (written_bytes < 4){ // padding
	  int diff = 4 - written_bytes;
	  for (int pad = 0; pad < diff; pad++){
	    chunk[j] = chunk[j] | (pgm_read_dword_near(padding_vec + (padded_bytes_so_far % PADDING_VEC_SIZE))
				   << ((diff -1 -pad) * 8));
	    written_bytes_so_far++;
	    padded_bytes_so_far++;
	    if (padded_bytes_so_far == num_octects_padding){
	      pad_length(to_encode, chunk);
	      stop_fill = 1;
	      break;
	    }
	  }
	}
      }
    }

    uint32_t w[64] = {0x0};

    // copy
    for (int i = 0; i < 16; i++){
      w[i] = chunk [i];
    }

    // extend
    extend_chunk(w);

    // initialize hash
    uint32_t a = starting_hash[0];
    uint32_t b = starting_hash[1];
    uint32_t c = starting_hash[2];
    uint32_t d = starting_hash[3];
    uint32_t e = starting_hash[4];
    uint32_t f = starting_hash[5];
    uint32_t g = starting_hash[6];
    uint32_t h = starting_hash[7];

    // compress
    for (int ct = 0; ct < 64; ct++){
      uint32_t s1   = rotate_right(e,  6) ^
	              rotate_right(e, 11) ^
	              rotate_right(e, 25);
      uint32_t ch   = (e & f) ^ ((~ e) & g);
      uint32_t tmp1 = h + s1 + ch + pgm_read_dword_near(k + ct) +
	              w[ct];
      uint32_t s0   = rotate_right(a,  2) ^
	              rotate_right(a, 13) ^
	              rotate_right(a, 22);
      uint32_t maj  = (a & b) ^ (a & c) ^ (b & c);
      uint32_t tmp2 = s0 + maj;

      h             = g;
      g             = f;
      f             = e;
      e             = d + tmp1;
      d             = c;
      c             = b;
      b             = a;
      a             = tmp1 + tmp2;
    }

    starting_hash[0] = starting_hash[0] + a;
    starting_hash[1] = starting_hash[1] + b;
    starting_hash[2] = starting_hash[2] + c;
    starting_hash[3] = starting_hash[3] + d;
    starting_hash[4] = starting_hash[4] + e;
    starting_hash[5] = starting_hash[5] + f;
    starting_hash[6] = starting_hash[6] + g;
    starting_hash[7] = starting_hash[7] + h;

  }

  // fill results buffer
  char offset = 0;
  for (int k = 0; k < 8; k++){
    char tmp[9];
    // should be PRIx32, but sadly does not seems to works :(
    sprintf(tmp, "%.8lx", starting_hash[k]);
    strncpy(results + offset, tmp, 8);
    offset+=8;
  }
  results[64] = '\0';
  return results;
}
