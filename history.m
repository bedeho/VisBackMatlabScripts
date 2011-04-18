
% HISTORY OF NEURON
% Input=========
% fileID: fileID of open weight file
% neuronOffsets: cell array giving byte offsets (rel. to 'bof') of neurons 
% region: neuron region
% col: neuron column
% row: neuron row
% depth: neuron depth
% Output========
% history: 

function [activity] = history(fileID, historyDimensions, neuronOffsets, region, depth, row, col, objects, transforms, epochs, ticks)

    % Import global variables
    global SOURCE_PLATFORM_FLOAT;
   
    % Find offset of neuron region.(depth,i,j)'s data stream
    streamStart = neuronOffsets{region}{col,row,depth}.offset;
    
    % Allocate history array
    activity = zeros(length(transforms), length(objects), length(ticks), length(epochs));
    
    % Iterate history
    for e = 1:length(epochs),
        for o = 1:length(objects),
            for t = 1:length(transforms),
                for ti= 1:length(ticks),
                    % Seek to correct location
                    offset = streamStart + (epochs(e) - 1)*historyDimensions.epochSize + (objects(o) - 1)*historyDimensions.objectSize + (transforms(t) - 1)*historyDimensions.transformSize + (ticks(ti) - 1)*historyDimensions.tickSize;
                    fseek(fileID, offset, 'bof');
                    
                    %Read
                    activity(t,o,ti,e) = fread(fileID, 1, SOURCE_PLATFORM_FLOAT);
                end
            end
        end
    end