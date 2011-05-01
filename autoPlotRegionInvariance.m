%
%  autoPlotRegionInvariance.m
%  VisBack
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

% PLOT REGION INVARIANCE FOR ALL SIMULATION FILES
% Input=========
% project: project name
% experiment: experiment name
% simulation: simulation name

function autoPlotRegionInvariance(project, experiment, simulation)

    PROJECTS_FOLDER = '/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/';  % must have trailing slash

    experimentFolder = [PROJECTS_FOLDER project '/Simulations/' experiment '/'];
    simulationFolder = [experimentFolder  simulation '/'];

    % Iterate all network result folders in this simulation folder
    listing = dir(simulationFolder);
    
    for d = 1:length(listing),

        % We are only looking for directories, but not the
        % 'Training' directory, since it has network evolution in training
        dir = listing(d).name;
        
        if listing(d).isdir == 1 && ~strcmp(dir,'Training') && ~strcmp(dir,'.') && ~strcmp(dir,'..'),
            
            [fig] = plotRegionInvariance([simulationFolder dir '/firingRate.dat']);
            
            saveas(f,[simulationFolder dir '/invariance.fig']) 
            
            close(fig);
        end
    end