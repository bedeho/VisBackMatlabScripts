
% BUILD SYNAPTIC WEIGHT MATRIX FOR A PARTICULAR DEPTH
% Input=========
% fileID: file id of open file
% headerSize: byte size of full header
% list: struct array (afferentSynapseCount,offsetCount) of neurons
% region: neuron region, V1 = 1
% col: neuron column
% row: neuron row
% depth: neuron depth
% sourceRegion: afferent region id (V1 = 1)
% sourceDepth: depth to plot in source region (first layer = 1)
% Output========

function [weightBox] = afferentSynapseMatrixForNeuron(fileID, headerSize, networkDimensions, list, region, col, row, depth, sourceRegion, sourceDepth)

    % Read file
    synapses = afferentSynapseListForNeuron(fileID, headerSize, list, region, col, row, depth);
    afferentSynapseCount = length(synapses);
    
    % Weight box
    sourceRegionDimension = networkDimensions(sourceRegion).dimension;
    weightBox = zeros(sourceRegionDimension, sourceRegionDimension);
    
    for s = 1:afferentSynapseCount,
        if synapses(s).regionNr == sourceRegion - 1 && synapses(s).depth == sourceDepth - 1
            weightBox(synapses(s).col, synapses(s).row) = synapses(s).weight;
        end
    end