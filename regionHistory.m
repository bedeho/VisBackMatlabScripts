%
%  regionHistory.m
%  VisBack
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Input=========
%  fileID: fileID of open weight file
%  historyDimensions:
%  neuronOffsets: cell array giving byte offsets (rel. to 'bof') of neurons 
%  region: neuron region
%  col: neuron column
%  row: neuron row
%  depth: neuron depth
%  maxEpoch (optional): largest epoch you are interested in
%  Output========
%  Activity history of region/depth: 4-d matrix (row, col, timestep, transform, object, epoch) 

function [activity] = regionHistory(fileID, historyDimensions, neuronOffsets, networkDimensions, region, depth) % , maxEpoch)

    % Import global variables
    global SOURCE_PLATFORM_FLOAT;

    % Validate input
    validateNeuron('neuronHistory.m', networkDimensions, region, depth);
    
    % Quick fix
    maxEpoch = historyDimensions.numEpochs;
    
    if maxEpoch < 1 || maxEpoch > historyDimensions.numEpochs,
        error([file ' error: epoch ' num2str(maxEpoch) ' does not exist'])
    end

    % Seek to offset of neuron region.(depth,1,1)'s data stream
    fseek(fileID, neuronOffsets{region}{1,1,depth}.offset, 'bof');
    
    % Read into buffer
    dimension = networkDimensions(region).dimension;
    streamSize = dimension * dimension * maxEpoch * historyDimensions.numObjects * historyDimensions.numTransforms * historyDimensions.numOutputsPrTransform;
    buffer = fread(fileID, streamSize, SOURCE_PLATFORM_FLOAT);
    
    % Make history array
    
    % When we are looking for full epoch history, we can get it all in one
    % chunk
    if maxEpoch == historyDimensions.numEpochs,
        activity = reshape(buffer, [historyDimensions.numOutputsPrTransform historyDimensions.numTransforms historyDimensions.numObjects maxEpoch dimension dimension]);
    else
        %When we are looking for partial epoch history, then we have to
        %seek betweene neurons, so we just use neuronHistory() routine
        error('not supported yet');
    end