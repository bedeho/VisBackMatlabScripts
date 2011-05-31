%
%  plotSimulationRegionInvariance.m
%  VisBack
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  PLOT REGION INVARIANCE FOR ALL SIMULATION FILES
%  Input=========
%  project: project name
%  experiment: experiment name
%  simulation: simulation name

function [summary] = plotSimulationRegionInvariance(project, experiment, simulation)

    % Import global variables
    declareGlobalVars();
    
    global PROJECTS_FOLDER;

    experimentFolder = [PROJECTS_FOLDER project '/Simulations/' experiment '/'];
    simulationFolder = [experimentFolder  simulation '/'];

    % Iterate all network result folders in this simulation folder
    listing = dir(simulationFolder);

    % Preallocate struct array for summary
    summary = [];
    counter = 1;

    % Iterate dir and do plot for each folder
    for d = 1:length(listing),
        
        % We are only looking for directories, but not the
        % 'Training' directory, since it has network evolution in training
        directory = listing(d).name;
        
        if listing(d).isdir == 1 && ~strcmp(directory,'Training') && ~strcmp(directory,'.') && ~strcmp(directory,'..'),
            
            [fig, fullInvariance, meanInvariance, nrOfSingleCell, multiCell] = plotRegionInvariance([simulationFolder directory '/firingRate.dat']);
            
            saveas(fig,[simulationFolder directory '/invariance.fig']);
            
            delete(fig);
            
            % Save results for summary
            summary(counter).directory = directory;
            summary(counter).fullInvariance = fullInvariance;
            summary(counter).meanInvariance = meanInvariance;
            summary(counter).multiCell = multiCell;
            summary(counter).nrOfSingleCell = nrOfSingleCell;
            
            counter = counter + 1;
        end
    end
    