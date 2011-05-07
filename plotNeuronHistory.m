%
%  plotNeuronHistory.m
%  VisBack
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Input=========
%  filename: filename of weight file
%  region: region to plot, V1 = 1
%  depth: region depth to plot
%  row: neuron row
%  col: neuron column
%  maxEpoch: last epoch to plot
%  Output========
%  Plots line plot of activity for spesific neuron, always 
%  picks last outputted time step of every transform and does
%  one line per object.

function plotNeuronHistory(filename, region, depth, row, col, maxEpoch)

    % Import global variables
    declareGlobalVars();

    % Open file
    fileID = fopen(filename);
    
    % Read header
    [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(fileID);
    
    if nargin < 6,
        maxEpoch = historyDimensions.numEpochs; % pick all epochs
    end
    
    % Get history array
    activity = neuronHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch);
    
    % Plot
    format('longE'); % output full floats, no rounding!!
    
    for e=1:maxEpoch,
        
        figure();
        
        for o=1:historyDimensions.numObjects,
            v = activity(historyDimensions.numOutputsPrTransform,:,o,e); % pick last tick
            %v
            plot(v);
            title(['Epoch: ' num2str(e) ', Object:' num2str(o) ', Tick: LAST']);
            hold all;
        end
    end