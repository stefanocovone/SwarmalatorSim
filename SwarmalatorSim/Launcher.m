% Launch a simulation for the swarmalators system:
% 
% The codes for each of the simulations are:
% 1   - Single
% 2   - SyncRadii
% 3   - PhaseWaveRadii
% 4   - Parallel
% 5   - Disorder
% 6   - Bifurcation
% 7   - ParallelForced
% 8   - Forced
% 9   - Partial
% 10  - Pinning
% 11  - PinningFixedJ
% 12  - PinningTs
%
% If you want to define you simulation, save it in src/launcher
% and add the relative entry to this file.

function Launcher(simNumber)

close all
clc

% Add src folder and its subfolders to path
addpath(genpath('src'));


switch simNumber
    case 1   
        LauncherSingle
    case 2   
        LauncherSyncRadii
    case 3     
        LauncherPhaseWaveRadii
    case 4     
        LauncherParallel
    case 5     
        LauncherDisorder
    case 6     
        LauncherBifurcation
    case 7    
        LauncherParallelForced
    case 8     
        LauncherForced
    case 9     
        LauncherPartial
    case 10    
        LauncherPinning
    case 11    
        LauncherPinningFixedJ
    case 12    
        LauncherPinningTs
    otherwise
        disp('Invalid simulation code')
end


