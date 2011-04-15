
function [weightBox] = afferentSynapseMatrixForNeuron(fileID, headerSize, list, region, col, row, depth, sourceRegion, sourceDepth)

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