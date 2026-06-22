# STK Radio Occultation Simulations using MATLAB
## Introduction
This program opens an STK scenario for radio occultation and extracts and saves access data. It can also process access data to create plots or compute statistics.

## Running the Program
To fully run the program, execute the files in the following order: <br>
1. STKSetup.m <br>
-> Opens the STK scenario (this will take awhile).
2. GetAccess.m <br>
-> Gets the necessary access data and write it to output text files (this takes A LONG time)
3. ProcessTimes.m <br>
-> Reads in any output files and processes the data.

Note that you only have to run STKSetup and GetAccess once whenever the scenario is changed. ProccessTimes can be executed as long as output files exist.
