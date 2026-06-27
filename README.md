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

<ins>Functions:<ins> <br>
* GetFileFormat.m
  * Returns the options for reading in a file containing 
access data. This function assumes variable types for each column.
  * Inputs:
     * filePath (string) - Path to the file to import options from
     * ELEMENTS (string array) - Array containing all variable names
  * Output:
     *  opt - Contains the structure of the table, including variable name and type



Note that you only have to run STKSetup and GetAccess once whenever the scenario is changed. ProccessTimes can be executed as long as output files exist.
## Results
There was a radio occultation with 3D positioning requirements 16.31% of the time and the daily average was 3 hours, 54 minutes and 54 seconds. Additionally, the average duration was 1 minute and 52 seconds. The following graph shows when SAT-2 has at least 5 seconds of radio occultation with 3D positioning: <br>
<img width="2466" height="1342" alt="image" src="https://github.com/user-attachments/assets/ba3a7b09-5fb9-431c-93c5-2ba0c09256cd" />
The latitude intervals were also graphed below where each line represents a radio occultation: <br>
<img width="2474" height="1266" alt="image" src="https://github.com/user-attachments/assets/ec9c3130-14f2-4b75-8c37-f4441d65d653" />

