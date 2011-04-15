
% Load weight file header
% Expects current file position to be at first byte of file
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
% Expects current file position to be at first byte of indegree header
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
                    afferentSynapseCount = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
                    list{r}(j,i,d) = struct('afferentSynapseCount', afferentSynapseCount, 'offsetCount' , offsetCount);
                    offsetCount = offsetCount + afferentSynapseCount;
                end
            end       
        end
    end
    
afferentSynapseLists = list;