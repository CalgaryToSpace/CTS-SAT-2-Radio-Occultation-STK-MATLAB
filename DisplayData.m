clear
close all

% List of data to run simulations (assumes first and second columns are always start/stop times)
ELEMENTS = {'StartTime'; 'StopTime'; 'ToStartLat'; 'ToStopLat'; 'To Start Lon'; 'To Stop Lon'};
START_DATE = '5-May-2026 18:00:00';

DATA_PATH = 'Output\Combined\occultation_2weeks';

% -----------------------------------------------------------------------------%

% Read in table
opt = GetFileFormat(DATA_PATH, ELEMENTS);
combinedOccultation = readtable(DATA_PATH, opt);

% Get durations
occultationDurations = combinedOccultation{:,2} - combinedOccultation{:,1};

% Filter for durations above 5s
condition = occultationDurations > seconds(5);
combinedOccultation = combinedOccultation(condition(:,1),:);
occultationDurations = occultationDurations(condition(:,1),:);

% Calculate some statistics ----------------------------------------------%
totalOccultationDuration =  sum(occultationDurations);
percentOccultation = hours(totalOccultationDuration) / (24*14);
dailyOccultationAvg = totalOccultationDuration / 14; % hours
occultationAvg = mean(occultationDurations);

fprintf("Percent occultation: %.4f%%\n", percentOccultation * 100)
fprintf("Daily occultation average: %s\n", string(dailyOccultationAvg))
fprintf("Occultation duration average: %s\n", string(occultationAvg))

% Plot the durations on time graph (filtered for <5) ---------------------%
figure
scatter(combinedOccultation{:,1}, occultationDurations, ".")
title("Duration of Radio Occultations With Atleast 4 GPS Access")
xlabel("Start Time of Interval")
ylabel("Duration")
grid on

% Assumes May 5th start date
xticks(datetime(START_DATE) + hours(0:24:336))
yticks(minutes(0:0.5:7))

% Plot the starting and stopping latitudes -------------------------------%
figure
hold on
for i = 1:size(combinedOccultation, 1)
    plot(combinedOccultation{i,3:4}, [occultationDurations(i,1) occultationDurations(i,1)], '-c')
end
title("Duration of Radio Occultation Shown as Latitude Intervals")
xlabel("Latitude (deg)")
ylabel("Duration")
grid on

% Turn off the horizontal lines
ax = gca;
ax.YGrid = "off";

% Plot the length of latitude intervals ---------------------------------%
latitudeLength = abs(combinedOccultation{:,4} - combinedOccultation{:,3});

figure
scatter(combinedOccultation{:,1}, latitudeLength, ".")
title("Latitude Length of Radio Occultations")
xlabel("Start Time of Interval")
xticks(datetime(START_DATE) + hours(0:24:336))

ylabel("Latitude Length (deg)")
ylim([-0.3 26.5])
grid on

% Interpolate scattered data (TODO)--------------------------------------------%
numBins = 100;
stepSize = 0.3;

% Get all path lengths
pathLengths = sqrt((combinedOccultation{:,4} - combinedOccultation{:,3}).^2 + ...
    (combinedOccultation{:,6} - combinedOccultation{:,5}).^2);

% Get number of points
numPoints = round(pathLengths ./ stepSize);

allPoints = zeros(sum(numPoints), 2);

pointStepSize = pathLengths ./ numPoints;

% All point latitudes and longitudes
for i = 1:size(combinedOccultation, 1)
    for j = 1:numPoints(i)
        % [Lat Lon]
        allPoints(sum(numPoints(1:i)) - numPoints(i) + j, 1) = ...
            combinedOccultation{i, 3} + (j - 1) * pointStepSize(i); 
        allPoints(sum(numPoints(1:i)) - numPoints(i) + j, 2) = ...
            combinedOccultation{i, 5} + (j - 1) * pointStepSize(i); 
    end
end


%allPoints = 