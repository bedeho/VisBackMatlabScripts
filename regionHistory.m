%
%  regionHistory.m
%  VisBack
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  HISTORY OF REGION NEURON
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

function [activity] = regionHistory(fileID, historyDimensions, neuronOffsets, networkDimensions, region, depth, maxEpoch)

    % Import global variables
    global SOURCE_PLATFORM_FLOAT;

    % Validate input
    validateNeuron('neuronHistory.m', networkDimensions, region, depth);
    
    if nargin < 7,
        if maxEpoch < 1 || maxEpoch > historyDimensions.numEpochs,
            error([file ' error: epoch ' num2str(maxEpoch) ' does not exist'])
        else
            numEpochs = maxEpoch;
        end
    else
        numEpochs = historyDimensions.numEpochs;
    end
    
    dimension = networkDimensions(region).dimension;
    
    % Seek to offset of neuron region.(depth,i,j)'s data stream
    fseek(fileID, neuronOffsets{region}{col,row,depth}.offset, 'bof');
    
    % Read into buffer
    streamSize = dimension * dimension * historyDimensions.objectSize * historyDimensions.transformSize * historyDimensions.tickSize;
    buffer = fread(fileID, streamSize, SOURCE_PLATFORM_FLOAT);
    
    % Make history array
    activity = reshape(buffer, [dimension dimension historyDimensions.numOutputsPrTransform historyDimensions.numTransforms historyDimensions.numObjects numEpochs]);   
    
    
    
    
    
    
    
    
    
    
    
    
    
        
    % ==================================================================================================================================
    % OLD TRASH
    % ==================================================================================================================================
    
    %{
    % Allocate history array
    activity = zeros(dimension, dimension, historyDimensions.numTransforms, historyDimensions.numObjects, historyDimensions.numOutputsPrTransform, length(epochs));
    
    for r = 1:dimension,
        for c = 1:dimension,
            
            % Find offset of neuron region.(depth,i,j)'s data stream
            streamStart = neuronOffsets{region}{c,r,depth}.offset;

            % Iterate history
            for e = 1:length(epochs),
                for o = 1:length(objects),
                    for t = 1:length(transforms),
                        for ti= 1:length(ticks),
                            % Seek to correct location
                            offset = streamStart + (epochs(e) - 1)*historyDimensions.epochSize + (objects(o) - 1)*historyDimensions.objectSize + (transforms(t) - 1)*historyDimensions.transformSize + (ticks(ti) - 1)*historyDimensions.tickSize;
                            fseek(fileID, offset, 'bof');

                            %Read
                            activity(c,r,t,o,ti,e) = fread(fileID, 1, SOURCE_PLATFORM_FLOAT);
                        end
                    end
                end
            end
        end
    end
    %}