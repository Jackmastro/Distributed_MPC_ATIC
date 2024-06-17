% Close all paths and then open all paths
clc
clearvars
close all

% Save the current paths
savedPaths = path;

% Remove all paths
restoredefaultpath;

disp("All paths restored correctly.")

% Get the full path of this setup file and main folder
pathThisSetupFile = mfilename('fullpath');
pathMainFolder = fileparts(pathThisSetupFile);
cd(pathMainFolder);

% Split and add the paths
allPaths = split(genpath(pathMainFolder), pathsep());
addpath(strjoin(allPaths, pathsep()));

disp("All paths added correctly.")

% Clear variables and close all figures
clearvars
close all
