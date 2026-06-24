clear
close all

% List of data to run simulations (assumes first and second columns are always start/stop times)
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

% Get options for reading tables
opt = GetFileFormat("Output\Uncombined\backwardsTimesAtleast4.txt", ELEMENTS);

% Read in access times
backwardsTimesAtleast4 = readtable("output\Uncombined\backwardsTimesAtleast4",opt);
backwardsTimesExactly3 = readtable("output\Uncombined\backwardsTimesExactly3",opt);
backwardsTimesExactly2 = readtable("output\Uncombined\backwardsTimesExactly2",opt);
backwardsTimesExactly1 = readtable("output\Uncombined\backwardsTimesExactly1",opt);

upwardsTimesAtleast4 = readtable("output\Uncombined\upwardsTimesAtleast4",opt);
upwardsTimesExactly3 = readtable("output\Uncombined\upwardsTimesExactly3",opt);
upwardsTimesExactly2 = readtable("output\Uncombined\upwardsTimesExactly2",opt);
upwardsTimesExactly1 = readtable("output\Uncombined\upwardsTimesExactly1",opt);

occultationTimes = readtable("output\Uncombined\occultationTimes",opt);

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

writetable(combinedOccultation, "Output\Combined\occultation_2weeks.txt")
