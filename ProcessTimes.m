clear
close all

% Unionizes any overlapping time intervals
function output = union(combined)
    n = size(combined, 1);
    overlapFlag = 1;

    while overlapFlag == 1
        overlapFlag = 0;
   
        for i=1:n - 1
            % Check if intervals overlap
            if combined(i,1) < combined(i+1,2) && combined(i,2) > combined(i+1,1)
                % New unionized interval
                combined(i,1) = min([combined(i,:) combined(i+1,:)]); % max of time
                combined(i,2) = max([combined(i,:) combined(i+1,:)]); % end of times

                combined(i+1,:) = NaT;
                overlapFlag = 1;
            end
        end

        % Remove any NaT values
        combined = combined(any(~isnat(combined), 2), :);
    end

    output = combined;
end

% Intersects any overlapping time intervals
function output = intersect(combined)
    n = size(combined, 1);
    i = 1; j = 2;

    % Checks if two intervals are overlapping
    isOverlap = @(one, two) one(1) < two(2) && one(2) > two(1);

    output = NaT(n, 2); % init matrix
    index = 1;

    % Get intersected intervals
    while(1)
        % Check if intervals overlap
        if isOverlap(combined(i,:), combined(j,:))
            output(index,1) = max([combined(i,1) combined(j,1)]); % max of the start times
            output(index,2) = min([combined(i,2) combined(j,2)]); % min of the end times

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

    % Remove NaT values
    output = output(~isnat(output(:,1)), :);
end

% Read in access times
backwardsTimesAtleast4 = string(readcell("output\backwardsTimesAtleast4","Delimiter",","));
backwardsTimesExactly3 = string(readcell("output\backwardsTimesExactly3","Delimiter",","));
backwardsTimesExactly2 = string(readcell("output\backwardsTimesExactly2","Delimiter",","));
backwardsTimesExactly1 = string(readcell("output\backwardsTimesExactly1","Delimiter",","));

upwardsTimesAtleast4 = string(readcell("output\upwardsTimesAtleast4","Delimiter",","));
upwardsTimesExactly3 = string(readcell("output\upwardsTimesExactly3","Delimiter",","));
upwardsTimesExactly2 = string(readcell("output\upwardsTimesExactly2","Delimiter",","));
upwardsTimesExactly1 = string(readcell("output\upwardsTimesExactly1","Delimiter",","));

occultationTimes = string(readcell("output\occultationTimes","Delimiter",","));

% Convert to datetime
inputFormat = "dd MMMM yyyy HH:mm:ss.SSS";
outputFormat = "dd-MMM-uuuu HH:mm:ss.SSS";

backwardsTimesAtleast4 = datetime(backwardsTimesAtleast4,"InputFormat", inputFormat, ...
    "Format", outputFormat);
backwardsTimesExactly3 = datetime(backwardsTimesExactly3,"InputFormat", inputFormat, ...
    "Format", outputFormat);
backwardsTimesExactly2 = datetime(backwardsTimesExactly2,"InputFormat", inputFormat, ...
    "Format", outputFormat);
backwardsTimesExactly1 = datetime(backwardsTimesExactly1,"InputFormat", inputFormat, ...
    "Format", outputFormat);

upwardsTimesAtleast4 = datetime(upwardsTimesAtleast4,"InputFormat", inputFormat, ...
    "Format", outputFormat);
upwardsTimesExactly3 = datetime(upwardsTimesExactly3,"InputFormat", inputFormat, ...
    "Format", outputFormat);
upwardsTimesExactly2 = datetime(upwardsTimesExactly2,"InputFormat", inputFormat, ...
    "Format", outputFormat);
upwardsTimesExactly1 = datetime(upwardsTimesExactly1,"InputFormat", inputFormat, ...
    "Format", outputFormat);

occultationTimes = datetime(occultationTimes,"InputFormat", inputFormat, ...
    "Format", outputFormat);

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

allAccessIntervals = [combinedAtleast4; combined1Back3Up; combined2Back2Up;...
    combined3Back1up; combined2Back3up; combined3Back2up];

% -------- Occultation with positioning -------%
combinedOccultation = sortrows([allAccessIntervals; occultationTimes], 1);
combinedOccultation = intersect(combinedOccultation);

% Filter for intervals less than 5 seconds
accessDurations = allAccessIntervals(:,2) - allAccessIntervals(:,1);
accessDurations = accessDurations(accessDurations > seconds(5));

occultationDurations = combinedOccultation(:,2) - combinedOccultation(:,1);
occultationDurations = occultationDurations(occultationDurations > seconds(5));

% Statistics
totalDuration = sum(accessDurations);
percentAccess = hours(totalDuration) / (24*14);

% Includes 4 GPS access for positioning and time synchronization
totalOccultationDuration =  sum(occultationDurations);
percentOccultation = hours(totalOccultationDuration) / (24*14);
dailyOccultationAvg = totalOccultationDuration / 14; % hours
occultationAvg = mean(occultationDurations);

% Plot the durations on time graph (unfiltered for <5)
figure
scatter(combinedOccultation(occultationDurations > seconds(5),1), ...
    occultationDurations, ".")
title("Duration of Radio Occultations With Atleast 4 GPS Access")
xlabel("Start Time of Interval")
ylabel("Duration")
grid on

% Assumes May 5th start date
xticks(datetime('5-May-2026 18:00:00') + hours(0:24:336))
yticks(minutes(0:0.5:3.5))
ylim([0 minutes(3.5)])
clear inputFormat outputFormat;