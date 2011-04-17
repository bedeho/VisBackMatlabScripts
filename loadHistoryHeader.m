
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
function [networkDimensions, numEpochs, numObjects, numTransforms, numOutputsPrTransform, headerSize] = loadHistoryHeader(fileID)

    % Import global variables
    global SOURCE_PLATFORM_USHORT;
    global SOURCE_PLATFORM_USHORT_SIZE;

    % Seek to start of file
    frewind(fileID);
    
    % Number of Epochs
    numEpochs = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
    
    % Number of Objects
    numObjects = fread(fileID, 1, SOURCE_PLATFORM_USHORT);

    % Number of Transforms
    numTransforms = fread(fileID, 1, SOURCE_PLATFORM_USHORT);

    % Number of Outputs per Transofmr
    numOutputsPrTransform = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
    
    % Number of regions
    numRegions = fread(fileID, 1, SOURCE_PLATFORM_USHORT);

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