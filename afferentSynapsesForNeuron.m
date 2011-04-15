
% Data type sizes for platform that generated the output files
SOURCE_PLATFORM_UINT = 'uint32';
SOURCE_PLATFORM_UINT_SIZE = 4;
SOURCE_PLATFORM_USHORT = 'uint16';
SOURCE_PLATFORM_USHORT_SIZE = 2;
SOURCE_PLATFORM_FLOAT = 'float';
SOURCE_PLATFORM_FLOAT_SIZE = 4;
SYNAPSE_ELEMENT_SIZE = (4 * SOURCE_PLATFORM_USHORT_SIZE + SOURCE_PLATFORM_FLOAT_SIZE); % regionNr >> depth >> row >> col >> weight

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

function [synapses] = afferentSynapsesForNeuron(fileID, headerSize, list, region, col, row, depth)
   
    % Find offset of synapse list of neuron region.(depth,i,j)
    offsetCount = list{region}(col,row,depth).offsetCount;
    fseek(fileID, headerSize + offsetCount * SYNAPSE_ELEMENT_SIZE, 'bof');
    
    % Allocate synapse struct array
    afferentSynapseCount = list{region}(col,row,depth).afferentSynapseCount;
    synapses(afferentSynapseCount).regionNr = [];
    synapses(afferentSynapseCount).depth = [];
    synapses(afferentSynapseCount).row = [];
    synapses(afferentSynapseCount).col = [];
    synapses(afferentSynapseCount).weight = [];
    
    % Weight box
    weightBox = zeros(col, row, depth);
    
    % Fill synapses and weightBox
    for s = 1:afferentSynapseCount,
        synapses(s).regionNr = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        synapses(s).depth = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        synapses(s).row = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        synapses(s).col = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        synapses(s).weight = fread(fileID, 1, SOURCE_PLATFORM_FLOAT);
    end
