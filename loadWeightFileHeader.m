%
%  loadWeightFileHeader.m
%  VisBack
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

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
    global SOURCE_PLATFORM_USHORT_SIZE;

    % Seek to start of file
    frewind(fileID);
    
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
    
    % We compute the size of header just read
    headerSize = inDegreeHeaderSize + SOURCE_PLATFORM_USHORT_SIZE*(1 + 2 * numRegions);