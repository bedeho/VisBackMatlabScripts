
% LOAD HEADER OF WEIGHT FILE
% Input=========
% fileID: Id of open file
% Output========
% networkDimensions: struct array (dimension,depth) of regions (incl. V1)
% list: struct array (afferentSynapseCount,offsetCount) of neurons
% bytesRead: bytes read, this is where the file pointer is left
function [networkDimensions, list, headerSize] = loadWeightFileHeader(fileID)

    % Import global variables
    global SOURCE_PLATFORM_USHORT;

    % Seek to start of file
    fseek(fileID, 0, 'bof');
    
    % Read number of regions
    numRegions = fread(fileID, 1, SOURCE_PLATFORM_USHORT);

    % Preallocate struct array
    networkDimensions(numRegions).dimension = [];
    networkDimensions(numRegions).depth = [];
    
    % Read dimensions
    for r=1:numRegions,
        networkDimensions(r).dimension = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        networkDimensions(r).depth = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
    end
    
    [list, inDegreeHeaderSize] = inDegreeHeader(fileID, networkDimensions);
    headerSize = inDegreeHeaderSize + SOURCE_PLATFORM_USHORT(1 + 2 * numRegions);