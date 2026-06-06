clear
close all

% Make sure STK is CLOSED (will likely take a long time to load, don't
% worry when its not responding)
uiApplication = actxserver('STK.Application');
root = uiApplication.Personality2;

uiApplication.Visible = 1;

% Allows us to access objects in scenario
scenarioPath = "C:\Users\roblo\OneDrive - University of Calgary\Desktop\STK files\RadioOccultation\RadioOccultation.sc";
root.LoadScenario(scenarioPath);

% Scenario object
scenario = root.CurrentScenario;

clear scenarioPath;