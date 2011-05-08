
% LOAD HEADER OF HISTORY FILE
% Input=========
% fileID: Id of open file
% Output========
% networkDimensions: struct array (dimension,depth) of regions (incl. V1)
% historyDimensions: struct
% (numEpochs,numObjects,numTransforms,numOutputsPrTransform)
% headerSize: bytes read, this is where the file pointer is left

function [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(fileID)

    % Import global variables
    global SOURCE_PLATFORM_USHORT;
    global SOURCE_PLATFORM_USHORT_SIZE;
    global SOURCE_PLATFORM_FLOAT_SIZE;

    % Seek to start of file
    frewind(fileID);
    
    % Read history dimensions & number of regions
    v = fread(fileID, 5, SOURCE_PLATFORM_USHORT);
    
    historyDimensions.numEpochs = v(1);
    historyDimensions.numObjects = v(2);
    historyDimensions.numTransforms = v(3);
    historyDimensions.numOutputsPrTransform = v(4);
    numRegions = v(5);
   
    % Compound stream sizes
    historyDimensions.transformSize = historyDimensions.numOutputsPrTransform;
    historyDimensions.objectSize = historyDimensions.transformSize * historyDimensions.numTransforms;
    historyDimensions.epochSize = historyDimensions.objectSize * historyDimensions.numObjects;
    historyDimensions.streamSize = historyDimensions.epochSize * historyDimensions.numEpochs;

    % Preallocate struct array
    networkDimensions(numRegions).dimension = [];
    networkDimensions(numRegions).depth = [];
    
    % Read dimensions
    for r=1:numRegions,
        networkDimensions(r).dimension = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        networkDimensions(r).depth = fread(fileID, 1, SOURCE_PLATFORM_USHORT); 
    end
    
    % We compute the size of header just read
    headerSize = SOURCE_PLATFORM_USHORT_SIZE*(5 + 2 * numRegions);
    
    % Compute and store the offset of each neuron's datastream in the file, not V1
    %neuronOffsets = cell(numRegions,1); 
    offset = headerSize; 
    nrOfNeurons = 1;
    for r=2:numRegions,
        neuronOffsets{r} = cell(networkDimensions(r).dimension, networkDimensions(r).dimension, networkDimensions(r).depth);
        
        for d=1:networkDimensions(r).depth, % Region depth
            for i=1:networkDimensions(r).dimension, % Region row
                for j=1:networkDimensions(r).dimension, % Region col
                    
                    neuronOffsets{r}{j,i,d} = struct('offset', offset ,'nr' ,nrOfNeurons);
                    
                    offset = offset + historyDimensions.streamSize * SOURCE_PLATFORM_FLOAT_SIZE;
                    nrOfNeurons = nrOfNeurons + 1;
                end
            end
        end
    end
    