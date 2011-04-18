
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
    streamStart = neuronOffsets{region}(col,row,depth).offset;
    fseek(fileID, streamStart, 'bof');
    
    % Allocate history array
    activity = zeros(length(objects), length(transforms), length(epochs), length(ticks));
    
    % Iterate history
    for e = length(epochs),
        for o = length(objects),
            for t = length(transforms),
                for ti= length(ticks),
                    
                    fseek(fileID,
                end
            end
        end
    end
    
    
    
    
    
    
    
    
    
    
    
    
    afferentSynapseCount = list{region}{col,row,depth}.afferentSynapseCount;
    synapses(afferentSynapseCount).regionNr = [];
    synapses(afferentSynapseCount).depth = [];
    synapses(afferentSynapseCount).row = [];
    synapses(afferentSynapseCount).col = [];
    synapses(afferentSynapseCount).weight = [];
    
    % Fill synapses
    for s = 1:afferentSynapseCount,
        synapses(s).regionNr = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        synapses(s).depth = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        synapses(s).row = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        synapses(s).col = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        synapses(s).weight = fread(fileID, 1, SOURCE_PLATFORM_FLOAT);
    end