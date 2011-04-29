%
%  plotRegionStability.m
%  VisBack
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

% PLOT REGION STABILITY HISTORY
% Input=========
% filename: filename of weight file
% region: region to plot, V1 = 1
% depth: region depth to plot
% row: neuron row
% col: neuron column
% objects:
% transforms:
% epochs:
% ticks:
% Output========
%
% 'D:\Oxford\Work\Projects\VisBack\Simulations\1Object\1Epoch\firingRate.da
% t'

function [] = plotRegionStability(filename, region, depth, objects, epochs)

   % Import global variables
    declareGlobalVars();

    % Open file
    fileID = fopen(filename);
    
    % Read header
    [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(fileID)
    
    % Fill in missing arguments, 
    if nargin < 5,
        epochs = 1:historyDimensions.numEpochs;             % pick all epochs

        if nargin < 4,
            objects = 1:historyDimensions.numObjects;       % pick all transforms

            if nargin < 3,
                depth = 1;                                  % pick first layer
            end
        end
    end
    
    tick = historyDimensions.numOutputsPrTransform;        % pick last output
    transforms = 1:historyDimensions.numTransforms;        % pick all transforms

    % Get history array
    activity = regionHistory(fileID, historyDimensions, neuronOffsets, networkDimensions, region, depth, objects, transforms, epochs, tick);
    
    % Plot
    plotDim = ceil(sqrt(length(transforms)));
    stability = zeros(length(epochs) - 1); % To plot
    
    figure();
    for t=1:length(transforms),

        subplot(plotDim, plotDim, t);

        for o=1:length(objects),
            
            pastActive = find(activity(:,:,t,o,tick,1)); % Save first epoch

            for e=2:length(epochs),
                presentActive = find(activity(:,:,t,o,tick,e));                     % Find new activity
                stability(e - 1) = newValuesInSecond(pastActive, presentActive);    % Find overlap in new and old activity
                pastActive = presentActive;                                         % Save new activity
            end
            
            plot(stability);
            title(['Transform : ', num2str(transforms(t))]);
            hold on;
            
            %lighting phong;
            %view([90,90]); 
            %axis([1 regionDimension 1 regionDimension 0 1]);
        end
    end
    
    function [res] = newValuesInSecond(first, second)
        res = 0;
        for s=1:length(second),
            
            new = true; % assume second(s) is not present in first
            for f=1:length(first),
                if(second(s) == first(f)), new = false; end
            end
            
            if(new), res = res + 1; end
        end
        