
% get me a topographic matrix of all synapse strengths from neuron
% region.(depth,i,j) in to region sourceRegion
function plotAfferentSynapses(sourceRegion, region, col, row, depth, sourceDepth)

    % Open file
    fileID = fopen('D:\Oxford\Work\Projects\VisBack\Simulations\1Object\BlankNetwork.txt');
    
    % Read header
    [networkDimensions, list, bytesRead] = loadWeightFileHeader(fileID);

    % Read file
    [networkDimensions,synapses] = afferentSynapses(fileID, region, col, row, depth);
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