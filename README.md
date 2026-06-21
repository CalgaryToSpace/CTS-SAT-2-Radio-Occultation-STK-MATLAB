To fully run the program, execute the files in the following order: <br>
1. STKSetup.m <br>
-> Opens the STK file (this will take awhile).
2. GetAccess.m <br>
-> Gets the necessary access data and write it to output text files (this takes A LONG time)
3. ProcessTimes.m <br>
-> Reads in any output files and processes the data.

Note that STKSetup and GetAccess should only be executed whenever the scenario is changed to update the output data. ProccessTimes can be executed as long as output files exist.
