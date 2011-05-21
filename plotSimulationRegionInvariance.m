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
    numEntries = length(listing);

    % Preallocate struct array for summary
    summary = cell(numEntries,4);
    %{ struct array concat issues
    %summary(numEntries).simulation = [];
    %summary(numEntries).directory = [];
    %summary(numEntries).maxFullInvariance = [];
    %summary(numEntries).maxMean = [];
    %}
    
    % Iterate dir and do plot for each folder
    for d = 1:numEntries,

        % We are only looking for directories, but not the
        % 'Training' directory, since it has network evolution in training
        directory = listing(d).name;
        
        if listing(d).isdir == 1 && ~strcmp(directory,'Training') && ~strcmp(directory,'.') && ~strcmp(directory,'..'),
            
            [fig, maxFullInvariance, maxMean] = plotRegionInvariance([simulationFolder directory '/firingRate.dat']);
            
            saveas(fig,[simulationFolder directory '/invariance.fig']);
            
            delete(fig);
            
            % Save results for summary
            %{
            summary(d).simulation = simulation;
            summary(d).directory = directory;
            summary(d).maxFullInvariance = maxFullInvariance;
            summary(d).maxMean = maxMean;
            %}
            
            summary{d,1} = simulation;
            summary{d,2} = directory;
            summary{d,3} = maxFullInvariance;
            summary{d,4} = maxMean;
        end
    end
    