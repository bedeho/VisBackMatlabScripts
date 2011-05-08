%
%  afferentSynapseMatrix.m
%  VisBack
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  BUILD SYNAPTIC WEIGHT MATRIX FOR A PARTICULAR DEPTH
%  Input=========
%  fileID: file id of open file
%  headerSize: byte size of full header
%  list: struct array (afferentSynapseCount,offsetCount) of neurons
%  region: neuron region, V1 = 1
%  col: neuron column
%  row: neuron row
%  depth: neuron depth
%  sourceRegion: afferent region id (V1 = 1)
%  sourceDepth: depth to plot in source region (first layer = 1)
%  Output========

function [weightBox] = afferentSynapseMatrix(fileID, headerSize, networkDimensions, list, region, depth, row, col, sourceRegion, sourceDepth)

    % Read file
    synapses = afferentSynapseList(fileID, headerSize, list, region, depth, row, col);
    afferentSynapseCount = length(synapses);
    
    % Weight box
    sourceRegionDimension = networkDimensions(sourceRegion).dimension;
    weightBox = zeros(sourceRegionDimension, sourceRegionDimension);
    
    for s = 1:afferentSynapseCount,
        if synapses(s).regionNr == sourceRegion - 1 && synapses(s).depth == sourceDepth - 1
            weightBox(synapses(s).col, synapses(s).row) = synapses(s).weight;
        end
    end