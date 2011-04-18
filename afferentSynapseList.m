

% AFFERENT SYNAPSES FOR ONE NEURON
% Input=========
% fileID: fileID of open weight file
% region: neuron region
% col: neuron column
% row: neuron row
% depth: neuron depth
% sourceRegion: afferent region id (V1 = 1)
% sourceDepth: depth to plot in source region (first layer = 1)
% Output========
% synapses: Returns struct array of all synapses (regionNR,depth,row,col,weight) into neuron

function [synapses] = afferentSynapseList(fileID, headerSize, list, region, depth, row, col)

    % Import global variables
    global SOURCE_PLATFORM_USHORT;
    global SYNAPSE_ELEMENT_SIZE;
    global SOURCE_PLATFORM_FLOAT;
   
    % Find offset of synapse list of neuron region.(depth,i,j)
    offsetCount = list{region}{col,row,depth}.offsetCount;
    fseek(fileID, headerSize + offsetCount * SYNAPSE_ELEMENT_SIZE, 'bof');
    
    % Allocate synapse struct array
    afferentSynapseCount = list{region}{col,row,depth}.afferentSynapseCount;
    synapses(afferentSynapseCount).regionNr = [];
    synapses(afferentSynapseCount).depth = [];
    synapses(afferentSynapseCount).row = [];
    synapses(afferentSynapseCount).col = [];
    synapses(afferentSynapseCount).weight = [];
    
    % Fill synapses
    for s = 1:afferentSynapseCount,
        v = fread(fileID, 4, SOURCE_PLATFORM_USHORT);
        
        synapses(s).regionNr = v(1);
        synapses(s).depth = v(2);
        synapses(s).row = v(3);
        synapses(s).col = v(4);
        synapses(s).weight = fread(fileID, 1, SOURCE_PLATFORM_FLOAT);
    end
