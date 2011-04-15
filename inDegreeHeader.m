
% LOAD INDEGREE HEADER
% Input=========
% fileID: Id of open file, expects current file position to be at first
% byte of indegree header
% networkDimensions: struct array (dimension,depth) of regions (incl. V1)
% Output========
% list: struct array (afferentSynapseCount,offsetCount) of neurons
% bytesRead: bytes read, this is where the file pointer is left
function [list, inDegreeHeaderSize] = inDegreeHeader(fileID, networkDimensions)

    % Number of regions, NOT counting V1
    numRegions = length(networkDimensions) - 1;
    
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
    
    inDegreeHeaderSize = offsetCount * SYNAPSE_ELEMENT_SIZE;