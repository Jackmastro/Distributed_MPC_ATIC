clc
clearvars
close all

pathThisSetupFile = mfilename('fullpath');
pathMainFolder = fileparts(pathThisSetupFile);
cd(pathMainFolder);

allPaths = split(genpath(pathMainFolder), pathsep());
addpath(strjoin(allPaths, pathsep()));

disp("All paths added correctly.")