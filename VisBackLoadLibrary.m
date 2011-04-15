
% Data type sizes for platform that generated the output files
% SOURCE_PLATFORM_UINT = 'uint32';
SOURCE_PLATFORM_USHORT = 'uint16';
SOURCE_PLATFORM_USHORT_SIZE = 2;
SOURCE_PLATFORM_FLOAT = 'float';
SOURCE_PLATFORM_FLOAT_SIZE = 4;
SYNAPSE_ELEMENT_SIZE = (4 * SOURCE_PLATFORM_USHORT_SIZE + SOURCE_PLATFORM_FLOAT_SIZE); % regionNr >> depth >> row >> col >> weight

% Returns struct array of all synapses from neuron r1.(d,i,j)    
function [networkDimensions, synapses] = afferentSynapses(filename, region, col, row, depth)
    
    % Open file
    fileID = fopen(filename);
    
    % Read header
    [networkDimensions,afferentSynapseLists] = loadNetworkHeader(fileID);
    
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
    
afferentSynapses = [networkDimensions, synapses];

% Load weight file header
function [networkDimensions, afferentSynapseLists] = loadNetworkHeader(fileID)

    % Read number of regions
    numRegions = fread(fileID, 1, SOURCE_PLATFORM_USHORT);

    % Preallocate struct array
    networkDimensions(r).dimension = [];
    networkDimensions(r).depth = [];

    % Read dimensions
    for r=1:numRegions,
        networkDimensions(r).dimension = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        networkDimensions(r).depth = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
    end

loadNetworkHeader = [networkDimensions, afferentSynapseLists(fileID, numRegions, networkDimensions)];

% Load afferent synapse list
function [afferentSynapseLists] = afferentSynapseLists(fileID, numRegions, networkDimensions)

    list = cell(numRegions,1); 

    % Build list of afferentSynapse count for all neurons, and
    % cumulative sum over afferentSynapseLists up to each neuron (count),
    % this is for file seeking
    offsetCount = 0;
    for r=1:numRegions,
        list{r} = zeros(networkDimensions(r).dimension, networkDimensions(r).dimension, networkDimensions(r).depth);
        for d=1:networkDimensions(r).depth, % Region depth
            for i=1:networkDimensions(r).dimension, % Region row
                for j=1:networkDimensions(r).dimension, % Region col
                    afferentSynapses = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
                    list{r}(j,i,d) = struct('afferentSynapseCount', afferentSynapses, 'offsetCount' , offsetCount);
                    offsetCount = offsetCount + afferentSynapses;
                end
            end       
        end
    end
    
afferentSynapseLists = list;