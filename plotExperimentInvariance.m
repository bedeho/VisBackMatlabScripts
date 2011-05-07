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
    
    totalSummary = cell(1,4); % empty dummy shit, take away later
    
    for d = 1:length(listing),

        % We are only looking for directories, but not the
        % 'Filtered' directory, since it has filtered output
        directory = listing(d).name;

        if listing(d).isdir == 1 && ~any(strcmp(directory, {'Filtered', 'Images', '.', '..'})),
            
            [summary] = plotSimulationRegionInvariance(project, experiment, directory);
            
            %totalSummary = mergeStructArray(totalSummary, summary);
            totalSummary = [totalSummary; summary];
        end
        
    end
    
    % Save results for summary
    fid = fopen([experimentFolder 'summary-' date() '-' num2str(now) '.txt'], 'w'); % did note use datestr(now) since it has string
    
    for s=1:length(totalSummary),
        fprintf(fid, '%s %s %d %d\n', totalSummary{s,1}, totalSummary{s,2}, totalSummary{s,3}, totalSummary{s,4});
        % fprintf(fid, '%s %s %d %d\n', totalSummary(s).simulation, totalSummary(s).directory, totalSummary(s).maxFullInvariance, totalSummary(s).maxMean);
    end
 
    fclose(fid);
        
% http://blogs.mathworks.com/loren/2009/10/15/concatenating-structs/#10 
%{
function res = mergeStructArray(sa1, sa2)

    if isempty(sa1),
        res = sa2;
    elseif isempty(sa2),
        res = sa1;
    else
        res = cell2struct([struct2cell(sa1) ; struct2cell(sa2)], [fieldnames(sa1); fieldnames(sa2)], 1);
    end
%}