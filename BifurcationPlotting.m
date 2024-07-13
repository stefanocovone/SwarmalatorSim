% Main script to call plotting functions

clear
close all
clc

% Add src folder and its subfolders to path
addpath(genpath('src'));

% Define input arguments for the first function
dataFolder = 'Data';
fileName1 = 'simulation_results_J05.mat';
savePath = 'Data';

% Call the first function with saving options
plot_order_parameters(dataFolder, fileName1, savePath, 'saveImage', true, 'saveEPS', true);

% Define input arguments for the second function
fileName2 = 'simulation_resultsN100.mat';

% Call the second function with saving options
plot_heatmaps_with_regression(dataFolder, fileName2, savePath, 'saveImage', true, 'saveEPS', true);

% Define the sigma values to be plotted
sigma_values = [0, 0.01, 0.02, 0.03];

% Call the plot_S_vs_K_for_sigma function
plot_S_vs_K_for_sigma(dataFolder, sigma_values, savePath, ...
    'saveImage', true, ...
    'saveEPS', true);
