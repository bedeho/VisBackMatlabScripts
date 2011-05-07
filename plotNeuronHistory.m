%
%  plotNeuronHistory.m
%  VisBack
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  PLOT NEURON HISTORY
%  Input=========
%  filename: filename of weight file
%  region: region to plot, V1 = 1
%  depth: region depth to plot
%  row: neuron row
%  col: neuron column
%  Output========
%
% 'D:\Oxford\Work\Projects\VisBack\Simulations\1Object\1Epoch\firingRate.dat'

function plotNeuronHistory(filename, region, depth, row, col)

    % Import global variables
    declareGlobalVars();

    % Open file
    fileID = fopen(filename);
    
    % Read header
    [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(fileID);
    
    % Get history array
    activity = neuronHistory(fileID, historyDimensions, neuronOffsets, region, depth, row, col);
    
    % Plot
    format('longE'); % output full floats, no rounding!!
    
    figure();
    for o=1:length(objects),
        v = activity(1,:,o,e);
        %v
        plot(v);
        title(['Epoch: ' num2str(epochs(e)) ', Object:' num2str(objects(o)) ', Tick: LAST']);
        hold all;
    end

    
       

