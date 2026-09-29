# include <stdio.h>
# include <sys/time.h>
/*********************************************************************/
// Task 1
//Please include necessary .h file for the program 

# include <wiringPi.h>
# include <wiringPiI2C.h>
# include "ads1115.h"

/*********************************************************************/

int main(){

	// for recording time for periodic task
	struct timeval t_start;
	struct timeval t_end;
	float  start, end, t_du;
	float  period = 20000; // target period in microseconds
	float  delay_con = 70; // correction constant in microseconds
	float  delay = period; // initialize delay (microseconds)
	
	/*********************************************************************/
	// Task 2
	// Please fill in the address of the i2c device, i.e., 0x??, pinBase and the pin you use for measurement
	int i2cAddr = 0x48;
	int pinBase = 100;
	int pinused = 0;
	/*********************************************************************/
	
	/*********************************************************************/
	// Task 3
	//Please define variables for your program 
	
	FILE *fp;
	float measure = 0;
	double elapsed_seconds = 0.0; // elapsed time in seconds


	/*********************************************************************/
	
	/*********************************************************************/
	// Task 4
	//Please put your code for initializing wiringPi and setting up ads1115

	wiringPiSetup();
	ads1115Setup(pinBase, i2cAddr);

	/*********************************************************************/

	// total start to measure elapsed run time
	struct timeval t_total_start;
	gettimeofday(&t_total_start, NULL);

	while(elapsed_seconds < 10*60) { // run for 10 minutes
		// obtain the starting time point
		gettimeofday(&t_start, NULL);
		
		/*********************************************************************/
		// Task 5
		//Please write your codes for measurement and data recording
 
		measure = analogRead(pinBase+pinused);
		// convert raw to voltage (ADS1115 configured +/-4.096V)
		float voltage = measure * 4.096f / 32768.0f;

		// get current total elapsed time
		gettimeofday(&t_end, NULL);
		long total_elapsed_us = (t_end.tv_sec - t_total_start.tv_sec) * 1000000L + (t_end.tv_usec - t_total_start.tv_usec);
		elapsed_seconds = total_elapsed_us / 1e6;

		// append measurement: voltage and elapsed seconds
		fp = fopen("measurement.txt", "ab+");
		if (fp) {
			fprintf(fp, "%.6f\t%.6f\n", voltage, elapsed_seconds);
			fclose(fp);
		}
		// also print to stdout
		printf("t=%.6fs  voltage=%.6f V\n", elapsed_seconds, voltage);
 
 
		
		/*********************************************************************/	
		
		// calculate and setting time delay
		// calculate and setting time delay (microseconds)
		gettimeofday(&t_end, NULL);
		delay = period - ((t_end.tv_sec - t_start.tv_sec)*1000000 + (t_end.tv_usec - t_start.tv_usec)) - delay_con;

		if (delay < 0) {
			delay = 0;
		}
		// ensure proper type for delayMicroseconds
		delayMicroseconds((unsigned int)delay);
		
	}
	return 0;	
}