close all
% Make sure to run STKSetup first

% List of data to run simulations for
ELEMENTS = {'Start Time'; 'Stop Time'; 'To Start Lat'; 'To Stop Lat'};

% To get GPS access based on different access constraints
function [backwards, upwards] = getGPSAccess(constraints, restrictionType, restrictionNum ...
    , backwardsChain, upwardsChain, scenario, elementList)

    startTime = scenario.StartTime;
    stopTime = scenario.StopTime;

    % Set access constraint
    constraints.SetFromRestrictionType(restrictionType);
    constraints.FromRestriction.NumberOfObjects = restrictionNum;
    
    % Execute and get results
    accessObjectBackwards = backwardsChain.DataProviders.Item('Access Data');
    accessObjectUpwards = upwardsChain.DataProviders.Item('Access Data');
    
    % Get specific data for backwards chain
    backwards = getData(accessObjectBackwards, startTime, stopTime, elementList);
   
    % Get specific data for upwards chain
    upwards = getData(accessObjectUpwards, startTime, stopTime, elementList);
end

% Get the specified data
function [resultCell] = getData(accessObject, startTime, stopTime, ...
    elementList)

    elementNum = size(elementList, 1);
    
    % Execute the query
    results = ...
    accessObject.ExecElements(startTime, stopTime, elementList).DataSets.ToArray;

    % Data is given for each satellite in each column (must combine)
    rowNum = size(results, 1);
    resultCell = cell(rowNum * elementNum, elementNum);

    % For each satellite
    for i = 1:size(results,2) / elementNum
        resultCell(rowNum * (i-1) + 1 : rowNum * i,:) = ...
            results(:,elementNum * (i-1) + 1 : elementNum * i);
    end
end

function [output] = removeNaN(cell)
    rowHasNaN = any(cellfun(@(x) isnumeric(x) && any(isnan(x)), cell), 2);
    cell(rowHasNaN, :) = [];

    output = cell;
end

% Paths
backwardsChainPath = '/Chain/Backwards';
upwardsChainPath = '/Chain/Upwards';
occultationPath = '/Chain/Occultation';
gpsPath = '/Constellation/GPS';

% Get objects
backwardsChain = root.GetObjectFromPath(backwardsChainPath);
upwardsChain = root.GetObjectFromPath(upwardsChainPath);
occultationChain = root.GetObjectFromPath(occultationPath);
GPS = root.GetObjectFromPath(gpsPath);

constraints = GPS.Constraints;

% AT LEAST 4 
[backwardsTimesAtleast4, upwardsTimesAtleast4] = getGPSAccess(constraints, ...
    'eCnCnstrRestrictionAtLeastN', 4, backwardsChain, upwardsChain, scenario, ELEMENTS);

% EXACTLY 3 
[backwardsTimesExactly3, upwardsTimesExactly3] = getGPSAccess(constraints, ...
    'eCnCnstrRestrictionExactlyN', 3, backwardsChain, upwardsChain, scenario, ELEMENTS);

% EXACTLY 2 
[backwardsTimesExactly2, upwardsTimesExactly2] = getGPSAccess(constraints, ...
    'eCnCnstrRestrictionExactlyN', 2, backwardsChain, upwardsChain, scenario, ELEMENTS);

% EXACTLY 1 
[backwardsTimesExactly1, upwardsTimesExactly1] = getGPSAccess(constraints, ...
    'eCnCnstrRestrictionExactlyN', 1, backwardsChain, upwardsChain, scenario, ELEMENTS);

% OCCULTATION
startTime = scenario.StartTime;
stopTime = scenario.StopTime;
occultationObject = occultationChain.DataProviders.Item('Access Data');

% Set access constraint to any
constraints.SetFromRestrictionType('eCnCnstrRestrictionAnyOf');

% Get access
results = ...
occultationObject.ExecElements(startTime, stopTime, ELEMENTS).DataSets.ToArray;

% Get occultation chain
occultation = getData(occultationObject, startTime, stopTime, ELEMENTS);

% Remove rows with a NaN value
backwardsTimesAtleast4 = removeNaN(backwardsTimesAtleast4);
backwardsTimesExactly3 = removeNaN(backwardsTimesExactly3);
backwardsTimesExactly2 = removeNaN(backwardsTimesExactly2);
backwardsTimesExactly1 = removeNaN(backwardsTimesExactly1);

upwardsTimesAtleast4 = removeNaN(upwardsTimesAtleast4);
upwardsTimesExactly3 = removeNaN(upwardsTimesExactly3);
upwardsTimesExactly2 = removeNaN(upwardsTimesExactly2);
upwardsTimesExactly1 = removeNaN(upwardsTimesExactly1);

occultation = removeNaN(occultation);

% Write matrices
writecell(backwardsTimesAtleast4, "output\backwardsTimesAtleast4");
writecell(backwardsTimesExactly3, "output\backwardsTimesExactly3");
writecell(backwardsTimesExactly2, "output\backwardsTimesExactly2");
writecell(backwardsTimesExactly1, "output\backwardsTimesExactly1");

writecell(upwardsTimesAtleast4, "output\upwardsTimesAtleast4");
writecell(upwardsTimesExactly3, "output\upwardsTimesExactly3");
writecell(upwardsTimesExactly2, "output\upwardsTimesExactly2");
writecell(upwardsTimesExactly1, "output\upwardsTimesExactly1");

writecell(occultation, "output\occultationTimes");

%{
clearvars -except backwardsTimesAtleast4 backwardsTimesExactly3 ...
backwardsTimesExactly2 backwardsTimesExactly1 upwardsTimesAtleast4 ...
upwardsTimesExactly3 upwardsTimesExactly2 upwardsTimesExactly1 occultation ...
root scenario uiApplication;
%}
