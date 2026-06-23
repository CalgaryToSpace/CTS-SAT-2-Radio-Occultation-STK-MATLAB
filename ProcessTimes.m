clear
close all

% List of data to run simulations (assumes first and second columns are start/stop times)
ELEMENTS = {'StartTime'; 'StopTime'; 'ToStartLat'; 'ToStopLat'};

% --------------------------------------------------------------------------------%

% Unionizes any overlapping time intervals
function output = union(combined)
    overlapFlag = 1;

    while overlapFlag == 1
        n = size(combined, 1);
        overlapFlag = 0;
   
        for i=1:n - 1
            % Check if intervals overlap
            if combined{i,1} <= combined{i+1,2} && combined{i,2} >= combined{i+1,1}
                % Temporary arrays
                allTimes = [combined{i,1:2} combined{i+1,1:2}];
                allLats = [combined{i,3:4} combined{i+1,3:4}];

                % New unionized interval
                combined{i,1} = min(allTimes); % min of times
                combined{i,2} = max(allTimes); % max of times
                
                % Corresponding latitudes
                combined{i,3} = allLats(find(allTimes == combined{i,1}, 1)); 
                combined{i,4} = allLats(find(allTimes == combined{i,2}, 1));

                combined{i+1,1} = missing;
                overlapFlag = 1;
            end
        end

        % Remove any missing rows
        combined = combined(~ismissing(combined(:,1)), :);
    end

    output = combined;
end

% Intersects any overlapping time intervals
function output = intersect(combined)
    n = size(combined, 1);
    i = 1; j = 2;

    % Checks if two intervals are overlapping
    isOverlap = @(one, two) one{1,1} < two{1,2} && one{1,2} > two{1,1};

    output = combined([], :); % init table
    output = resize(output, n);

    index = 1;

    % Get intersected intervals
    while(1)
        % Check if intervals overlap
        if isOverlap(combined(i,:), combined(j,:))
            % Temporary arrays
            startTimes = [combined{i,1} combined{j,1}];
            stopTimes = [combined{i,2} combined{j,2}];

            startLats = [combined{i,3} combined{j,3}];
            stopLats = [combined{i,4} combined{j,4}];

            % New intersect intervals
            output{index,1} = max(startTimes); % max of the start times
            output{index,2} = min(stopTimes); % min of the end times

            % Corresponding lattitudes
            output{index,3} = startLats(find(startTimes == output{index,1}, 1));
            output{index,4} = stopLats(find(stopTimes == output{index,2}, 1));

            index = index + 1;
        end

        if j >= n
            break
        % Overlaps multiple intervals
        elseif isOverlap(combined(i,:), combined(j+1,:))
            j = j+1;
        else
            % Move both indices
            i = j;
            j = i+1; 
        end
    end

    % Remove missing rows
    output = output(~ismissing(output(:,1)), :);
end

% Set options for reading tables
opt = detectImportOptions("Output\backwardsTimesAtleast4.txt");

opt.Delimiter = ',';
opt.VariableTypes{1} = 'datetime';
opt.VariableTypes{2} = 'datetime';
opt.VariableTypes{3} = 'double';
opt.VariableTypes{4} = 'double';
opt.VariableNames = ELEMENTS;

% Date time formatting
opt = setvaropts(opt, ELEMENTS{1}, 'InputFormat', "dd MMMM yyyy HH:mm:ss.SSS");
opt = setvaropts(opt, ELEMENTS{2}, 'InputFormat', "dd MMMM yyyy HH:mm:ss.SSS");

% Read in access times
backwardsTimesAtleast4 = readtable("output\backwardsTimesAtleast4",opt);
backwardsTimesExactly3 = readtable("output\backwardsTimesExactly3",opt);
backwardsTimesExactly2 = readtable("output\backwardsTimesExactly2",opt);
backwardsTimesExactly1 = readtable("output\backwardsTimesExactly1",opt);

upwardsTimesAtleast4 = readtable("output\upwardsTimesAtleast4",opt);
upwardsTimesExactly3 = readtable("output\upwardsTimesExactly3",opt);
upwardsTimesExactly2 = readtable("output\upwardsTimesExactly2",opt);
upwardsTimesExactly1 = readtable("output\upwardsTimesExactly1",opt);

occultationTimes = readtable("output\occultationTimes",opt);

% Sort the rows (ascending order) based on the start time and union
% duplicates
backwardsTimesAtleast4 = union(sortrows(backwardsTimesAtleast4, 1));
backwardsTimesExactly3 = union(sortrows(backwardsTimesExactly3, 1));
backwardsTimesExactly2 = union(sortrows(backwardsTimesExactly2, 1));
backwardsTimesExactly1 = union(sortrows(backwardsTimesExactly1, 1));

upwardsTimesAtleast4 = union(sortrows(upwardsTimesAtleast4, 1));
upwardsTimesExactly3 = union(sortrows(upwardsTimesExactly3, 1));
upwardsTimesExactly2 = union(sortrows(upwardsTimesExactly2, 1));
upwardsTimesExactly1 = union(sortrows(upwardsTimesExactly1, 1));

occultationTimes = union(sortrows(occultationTimes, 1));

% ---------- Atleast 4 backwards & upwards ---------- %
combinedAtleast4 = sortrows([backwardsTimesAtleast4; upwardsTimesAtleast4], 1);

combinedAtleast4 = union(combinedAtleast4);

% ---------- 1 backwards, 3 upwards ------- %
combined1Back3Up = sortrows([backwardsTimesExactly1; upwardsTimesExactly3], 1);

combined1Back3Up = intersect(combined1Back3Up);

% ---------- 2 backwards, 2 upwards ------- %
combined2Back2Up = sortrows([backwardsTimesExactly2; upwardsTimesExactly2], 1);

combined2Back2Up = intersect(combined2Back2Up);

% ---------- 3 backwards, 1 upwards ------- %
combined3Back1up = sortrows([backwardsTimesExactly3; upwardsTimesExactly1], 1);

combined3Back1up = intersect(combined3Back1up);

% ---------- 2 backwards, 3 upwards ------- %
combined2Back3up = sortrows([backwardsTimesExactly2; upwardsTimesExactly3], 1);

combined2Back3up = intersect(combined2Back3up);

% ---------- 3 backwards, 2 upwards ------- %
combined3Back2up = sortrows([backwardsTimesExactly3; upwardsTimesExactly2], 1);

combined3Back2up = intersect(combined3Back2up);

allAccessIntervals = sortrows([combinedAtleast4; combined1Back3Up; combined2Back2Up;...
    combined3Back1up; combined2Back3up; combined3Back2up], 1);

allAccessIntervals = union(allAccessIntervals);

% -------- Occultation with positioning -------%
combinedOccultation = sortrows([allAccessIntervals; occultationTimes], 1);
combinedOccultation = intersect(combinedOccultation);

% Get durations
occultationDurations = combinedOccultation{:,2} - combinedOccultation{:,1};

% Includes 4 GPS access for positioning and time synchronization
totalOccultationDuration =  sum(occultationDurations);
percentOccultation = hours(totalOccultationDuration) / (24*14);
dailyOccultationAvg = totalOccultationDuration / 14; % hours
occultationAvg = mean(occultationDurations);

% Plot the durations on time graph (filtered for <5)
condition = occultationDurations > seconds(5);
intervalFiltered = combinedOccultation(condition(:,1),:);
durationFiltered = occultationDurations(condition(:,1),:);

figure
scatter(intervalFiltered{:,1}, ...
    durationFiltered, ".")
title("Duration of Radio Occultations With Atleast 4 GPS Access")
xlabel("Start Time of Interval")
ylabel("Duration")
grid on

% Assumes May 5th start date
xticks(datetime('5-May-2026 18:00:00') + hours(0:24:336))
yticks(minutes(0:0.5:7))
ylim([0 minutes(7)])
clear inputFormat outputFormat;

% Plot the starting and stopping latitudes
figure
hold on
for i = 1:size(intervalFiltered, 1)
    plot(intervalFiltered{i,3:4}, [durationFiltered(i,1) durationFiltered(i,1)], '-c')
end
title("Duration of Radio Occultation Shown as Latitude Intervals")
xlabel("Latitude (deg)")
ylabel("Duration")
grid on

% Turn off the horizontal lines
ax = gca;
ax.YGrid = "off";