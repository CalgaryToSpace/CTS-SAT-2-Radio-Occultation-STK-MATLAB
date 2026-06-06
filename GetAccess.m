close all
% Make sure to run STKSetup first

% To get GPS access based on different access constraints
function [backwards, upwards] = getGPSAccess(constraints, restrictionType, restrictionNum ...
    , backwardsChain, upwardsChain, scenario)

    % Set access constraint
    constraints.SetFromRestrictionType(restrictionType);
    constraints.FromRestriction.NumberOfObjects = restrictionNum;
    
    % Execute and get results
    objectAccessBackwards = backwardsChain.DataProviders.Item('Object Access');
    objectAccessUpwards = upwardsChain.DataProviders.Item('Object Access');
    
    results = objectAccessBackwards.Exec(scenario.StartTime, scenario.StopTime);
    array = results.DataSets.ToArray;
    
    % Get start and end times for backwards chain
    CTSindex = (find(array(1,1:5:size(array,2)) == "NEW-CTS-SAT-1/Backwards") - 1) * 5 + 1;
    backwards = [array(:,CTSindex + 2), array(:,CTSindex + 3)];
    
    results = objectAccessUpwards.Exec(scenario.StartTime, scenario.StopTime);
    array = results.DataSets.ToArray;
    
    % Get start and end times for upwards chain
    CTSindex = (find(array(1,1:5:size(array,2)) == "NEW-CTS-SAT-1/Upwards") - 1) * 5 + 1;
    upwards = [array(:,CTSindex + 2), array(:,CTSindex + 3)];
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
    'eCnCnstrRestrictionAtLeastN', 4, backwardsChain, upwardsChain, scenario);

% EXACTLY 3 
[backwardsTimesExactly3, upwardsTimesExactly3] = getGPSAccess(constraints, ...
    'eCnCnstrRestrictionExactlyN', 3, backwardsChain, upwardsChain, scenario);

% EXACTLY 2 
[backwardsTimesExactly2, upwardsTimesExactly2] = getGPSAccess(constraints, ...
    'eCnCnstrRestrictionExactlyN', 2, backwardsChain, upwardsChain, scenario);

% EXACTLY 1 
[backwardsTimesExactly1, upwardsTimesExactly1] = getGPSAccess(constraints, ...
    'eCnCnstrRestrictionExactlyN', 1, backwardsChain, upwardsChain, scenario);

% OCCULTATION
occultationObject = occultationChain.DataProviders.Item('Object Access');

% Set access constraint
constraints.SetFromRestrictionType('eCnCnstrRestrictionAnyOf');

% Get access
results = occultationObject.Exec(scenario.StartTime, scenario.StopTime);
array = results.DataSets.ToArray;

% Get start and end times for occultation chain
CTSindex = (find(array(1,1:5:size(array,2)) == "NEW-CTS-SAT-1/Occultation") - 1) * 5 + 1;
occultation = [array(:,CTSindex + 2), array(:,CTSindex + 3)];

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
