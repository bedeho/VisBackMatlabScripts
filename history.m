
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

function [history] = history(fileID, neuronOffsets, region, depth, row, col, object, transform, epoch, tick)

    % Import global variables
    global SOURCE_PLATFORM_FLOAT;
   
    % Find offset of neuron region.(depth,i,j)'s data stream
    fseek(fileID, neuronOffsets{region}(col,row,depth).offset, 'bof');
    
    % Allocate synapse struct array
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