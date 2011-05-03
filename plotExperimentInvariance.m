%
%  plotRegionInvariance.m
%  VisBack
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  PLOT REGION INVARIANCE FOR ALL SIMULATION FILES IN ALL SIMULATIONS
%  Input=========
%  project: project name
%  experiment: experiment name
%  simulation: simulation name

function plotExperimentInvariance(project, experiment)

    PROJECTS_FOLDER = '/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/';  % must have trailing slash

    experimentFolder = [PROJECTS_FOLDER project '/Simulations/' experiment '/'];
    
    % Iterate simulations in this experiment folder
    listing = dir(experimentFolder); 
    
    totalSummary = [];
    
    for d = 1:length(listing),

        % We are only looking for directories, but not the
        % 'Filtered' directory, since it has filtered output
        directory = listing(d).name;
        
        simulationFolder = [experimentFolder  simulation '/'];
        
        if listing(d).isdir == 1 && ~strcmp(directory,'Filtered') && ~strcmp(directory,'.') && ~strcmp(directory,'..'),
            
            [summary] = plotRegionInvariance([simulationFolder directory '/firingRate.dat'], false);
            
            totalSummary = [totalSummary;summary];
            
        end
    end
    
    % Save results for summary
    fid = fopen([experimentFolder '/summary-' datestr() '-' num2str(now) '.txt']); % did note use datestr(now) since it has string
    
    for s=1:length(totalSummary),
        fprintf(fid, '%s %s %d %d \n', totalSummary(d).simulation, totalSummary(d).directory, totalSummary(d).maxFullInvariance, totalSummary(d).maxMean);
    end
 
    fclose(fid);