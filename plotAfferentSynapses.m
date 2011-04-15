
% PLOT SYNAPTIC WEIGHT MATRIX FOR NEURON
% Input=========
% filename: filename of weight file
% region: neuron region
% col: neuron column
% row: neuron row
% depth: neuron depth
% sourceRegion: afferent region id (V1 = 1)
% sourceDepth: depth to plot in source region (first layer = 1)
% Output========
%
% 'D:\Oxford\Work\Projects\VisBack\Simulations\1Object\BlankNetwork.txt'

function plotAfferentSynapses(filename, region, col, row, depth, sourceRegion, sourceDepth)

    % Open file
    fileID = fopen(filename);
    
    % Read header
    [networkDimensions, list, headerSize] = loadWeightFileHeader(fileID);

    % Read file
    synapses = afferentSynapsesForNeuron(fileID, headerSize, list, region, col, row, depth);
    afferentSynapseCount = length(synapses);
    
    % Weight box
    sourceRegionDimension = networkDimensions(sourceRegion).dimension;
    weightBox = zeros(sourceRegionDimension, sourceRegionDimension);
    
    for s = 1:afferentSynapseCount,
        if synapses(s).regionNr == sourceRegion && synapses(s).depth == sourceDepth
            weightBox(synapses(s).col, synapses(s).row, synapses(s).depth) = synapses(s).weight;
        end
    end
    
    plot(weightBox);