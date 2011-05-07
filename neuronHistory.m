%
%  neuronHistory.m
%  VisBack
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Input=========
%  fileID: fileID of open weight file
%  networkDimensions: 
%  historyDimensions: 
%  neuronOffsets: cell array giving byte offsets (rel. to 'bof') of neurons 
%  region: neuron region
%  col: neuron column
%  row: neuron row
%  depth: neuron depth
%  maxEpoch (optional): largest epoch you are interested in
%  Output========
%  Activity history of region: 4-d matrix (timestep, transform, object, epoch)

function [activity] = neuronHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch)

    % Import global variables
    global SOURCE_PLATFORM_FLOAT;

    % Validate input
    validateNeuron('neuronHistory.m', networkDimensions, region, depth, row, col);
    
    if nargin < 9,
        if maxEpoch < 1 || maxEpoch > historyDimensions.numEpochs,
            error([file ' error: epoch ' num2str(maxEpoch) ' does not exist'])
        else
            numEpochs = maxEpoch;
        end
    else
        numEpochs = historyDimensions.numEpochs;
    end
    
    % Seek to offset of neuron region.(depth,i,j)'s data stream
    fseek(fileID, neuronOffsets{region}{col,row,depth}.offset, 'bof');
    
    % Read into buffer
    streamSize = historyDimensions.objectSize * historyDimensions.transformSize * historyDimensions.tickSize;
    buffer = fread(fileID, streamSize, SOURCE_PLATFORM_FLOAT);
    
    % Make history array
    activity = reshape(buffer, [historyDimensions.numOutputsPrTransform historyDimensions.numTransforms historyDimensions.numObjects numEpochs]);
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    % ==================================================================================================================================
    % OLD TRASH
    % ==================================================================================================================================
    
    %activity = zeros(historyDimensions.numTransforms, historyDimensions.numObjects, historyDimensions.numOutputsPrTransform, numEpochs);
    %activity = 
    %{
    % Load history from buffer into activity array
    counter = 1;
    for e = 1:numEpochs,
        for o = 1:historyDimensions.numObjects,
            for t = 1:historyDimensions.numTransforms,
                for ti= 1:historyDimensions.numOutputsPrTransform,
                    activity(t,o,ti,e) = buffer(counter);
                    counter = counter + 1;
                end
            end
        end
    end
    %}
    
    %{
    function [activity] = neuronHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, objects, transforms, epochs, ticks)

    % Import global variables
    global SOURCE_PLATFORM_FLOAT;
   
    % Find offset of neuron region.(depth,i,j)'s data stream
    streamStart = neuronOffsets{region}{col,row,depth}.offset;
    
    % Allocate history array
    activity = zeros(length(transforms), length(objects), length(ticks), length(epochs));

    % Validate input
    validateNeuron('neuronHistory.m', networkDimensions, region, depth, row, col);
    validateHistory('neuronHistory.m', historyDimensions, objects, transforms, epochs, ticks);
    
    % Iterate history
    for e = 1:length(epochs),
        for o = 1:length(objects),
            for t = 1:length(transforms),
                for ti= 1:length(ticks),
                    
                    % Seek to correct location
                    offset = streamStart + (epochs(e) - 1)*historyDimensions.epochSize + (objects(o) - 1)*historyDimensions.objectSize + (transforms(t) - 1)*historyDimensions.transformSize + (ticks(ti) - 1)*historyDimensions.tickSize;
                    fseek(fileID, offset, 'bof');
                    
                    % Read
                    activity(t,o,ti,e) = fread(fileID, 1, SOURCE_PLATFORM_FLOAT);
                end
            end
        end
    end
    %}