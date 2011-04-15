
% Data type sizes for platform that generated the output files
SOURCE_PLATFORM_UINT = 'uint32';
SOURCE_PLATFORM_UINT_SIZE = 4;
SOURCE_PLATFORM_USHORT = 'uint16';
SOURCE_PLATFORM_USHORT_SIZE = 2;
SOURCE_PLATFORM_FLOAT = 'float';
SOURCE_PLATFORM_FLOAT_SIZE = 4;
SYNAPSE_ELEMENT_SIZE = (4 * SOURCE_PLATFORM_USHORT_SIZE + SOURCE_PLATFORM_FLOAT_SIZE); % regionNr >> depth >> row >> col >> weight

% Returns struct array of all synapses from neuron r1.(d,i,j)
function [networkDimensions, synapses, bytesRead] = afferentSynapsesForNeuron(fileID, region, col, row, depth)
    
    
    
    offsetCount = afferentSynapseLists{region}(col,row,depth).offsetCount;
    afferentSynapseCount = afferentSynapseLists{region}(col,row,depth).afferentSynapseCount;
    
    % Find offset of synapse list of neuron region.(depth,i,j)
    fseek(fileID, offsetCount * SYNAPSE_ELEMENT_SIZE, 'cof');
    
    % Synapse struct array
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
