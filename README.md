# STK Radio Occultation Simulations using MATLAB
## Introduction
This program opens an STK scenario for radio occultation and extracts and saves access data. It can also process access data to create plots or compute statistics.

## File Description
To fully run the program, execute the files in the following order: <br>
1. STKSetup.m <br>
* Opens STK and gets the scenario object for further processing. This code will take about 10 minutes to execute because it waits for STK to fully load. Do not worry if STK is not responding (it does this a lot).

2. GetAccess.m <br>
* Uses the root scenario object to get chain and GPS constellation objects.
* Obtains the following:
  * Start and end times of access intervals for both the upwards and backwards sensors. Gets data when there is access to at least 4 and exactly 3, 2, and 1 satellites. Also gets occultation access intervals.
  * Start and end latitudes of the access intervals
* Writes all access data to output files.
* This script will take a very long time, make sure to not close STK as it runs.

3. ProcessData.m <br>
* Reads all of the access arrays from their output files.
* Uses a union and intersect function to collapse overlapping intervals:
  * (at least 4 backwards) ∪ (at least 4 upwards)
  * (1 backwards) ∩ (3 upwards)
  * (2 backwards) ∩ (2 upwards)
  * (3 backwards) ∩ (1 upwards)
  * (2 backwards) ∩ (3 upwards)
  * (3 backwards) ∩ (2 upwards)
* Combines all unions and intersects to get only intervals of at least 4 satellite access.
* Perform (at least 1 occultation) ∩ (at least 4 satellite access) and writes results to a file
  
4. DisplayData.m
* Computes the durations of occultations with 3D positioning and filters for durations under 5 seconds.
* Computes some statistics on the durations and latitudes.
* Create plots on the data.


Note that you only have to run STKSetup and GetAccess once whenever the scenario is changed. ProccessTimes can be executed as long as output files exist.
