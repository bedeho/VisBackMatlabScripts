
% LOAD HEADER OF HISTORY FILE
% Input=========
% fileID: Id of open file
% Output========
% networkDimensions: struct array (dimension,depth) of regions (incl. V1)
% numEpochs: number of epochs
% numObjects: number of objects
% numTransforms: number of transforms
% numOutputsPrTransform: number of outputs per transform
% headerSize: bytes read, this is where the file pointer is left

function [networkDimensions, numEpochs, numObjects, numTransforms, numOutputsPrTransform, headerSize, neuronOffsets] = loadHistoryHeader(fileID)

    % Import global variables
    global SOURCE_PLATFORM_USHORT;
    global SOURCE_PLATFORM_USHORT_SIZE;
    global SOURCE_PLATFORM_FLOAT_SIZE;

    % Seek to start of file
    frewind(fileID);
    
    % Read history dimensions
    v = fread(fileID, 5, SOURCE_PLATFORM_USHORT);
    numEpochs = v(1);               % Number of Epochs
    numObjects = v(2);              % Number of Objects
    numTransforms = v(3);           % Number of Transforms
    numOutputsPrTransform = v(4);   % Number of Outputs per Transform
    numRegions = v(5);              % Number of Regions

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
    
    % Compute the offset of each neurons datastream in the file, not V1
    neuronOffsets = cell(numRegions - 1,1); 
    offset = headerSize;
    nrOfNeurons = 1;
    for r=2:numRegions,
        neuronOffsets{r} = zeros(networkDimensions(r).dimension, networkDimensions(r).dimension, networkDimensions(r).depth);
        for d=1:networkDimensions(r).depth, % Region depth
            for i=1:networkDimensions(r).dimension, % Region row
                for j=1:networkDimensions(r).dimension, % Region col
                    neuronOffsets{r}(j,i,d) = struct('offset',offset ,'nr' ,nrOfNeurons);
                    offset = offset + SOURCE_PLATFORM_FLOAT_SIZE*numEpochs*numObjects*numTransforms*numOutputsPrTransform;
                    nrOfNeurons = nrOfNeurons + 1;
                end
            end
        end
    end