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

    PROJECTS_FOLDER = '/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/';  % must have trailing slash

    experimentFolder = [PROJECTS_FOLDER project '/Simulations/' experiment '/'];
    simulationFolder = [experimentFolder  simulation '/'];

    % Iterate all network result folders in this simulation folder
    listing = dir(simulationFolder);
    numEntries = length(listing);

    % Preallocate struct array for summary
    summary(numEntries).simulation = [];
    summary(numEntries).directory = [];
    summary(numEntries).maxFullInvariance = [];
    summary(numEntries).maxMean = [];
    
    % Iterate dir and do plot for each folder
    for d = 1:numEntries,

        % We are only looking for directories, but not the
        % 'Training' directory, since it has network evolution in training
        directory = listing(d).name;
        
        if listing(d).isdir == 1 && ~strcmp(directory,'Training') && ~strcmp(directory,'.') && ~strcmp(directory,'..'),
            
            [fig, maxFullInvariance, maxMean] = plotRegionInvariance([simulationFolder directory '/firingRate.dat'], false);
            
            saveas(fig,[simulationFolder directory '/invariance.fig']);
            
            close(fig);
            
            % Save results for summary
            summary(d).simulation = simulation;
            summary(d).directory = directory;
            summary(d).maxFullInvariance = maxFullInvariance;
            summary(d).maxMean = maxMean;
        end
    end
    