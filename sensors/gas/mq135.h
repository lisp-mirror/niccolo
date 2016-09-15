/* This code derived from (c) 2016  G.Krocker (Mad Frog Labs) */

/* according to: https://github.com/GeorgK/MQ135 */

/* licensed under GPLv3 */

// mq135

#define SENSOR_PIN 2

/// The load resistance on the board
#define RLOAD 10.0

float getResistance() {
  int val = analogRead(SENSOR_PIN);
  return ((1023./(float)val) * 5. - 1.)*RLOAD;
}
