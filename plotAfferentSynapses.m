
% PLOT SYNAPTIC WEIGHT MATRIX FOR NEURON
% Input=========
% filename: filename of weight file
% region: neuron region, V1 = 1
% col: neuron column
% row: neuron row
% depth: neuron depth
% sourceRegion: afferent region id (V1 = 1)
% sourceDepth: depth to plot in source region (first layer = 1)
% Output========
%
% 'D:\Oxford\Work\Projects\VisBack\Simulations\1Object\BlankNetwork.txt'

function plotAfferentSynapses(filename, region, col, row, depth, sourceRegion, sourceDepth)

    % Import global variables
    declareGlobalVars();

    % Open file
    fileID = fopen(filename);
    
    % Read header
    [networkDimensions, list, headerSize] = loadWeightFileHeader(fileID);
    
    if nargin
    plotMatrix(fileID, headerSize, networkDimensions, list, region, col, row, depth, sourceRegion, sourceDepth);

function plotMatrix(fileID, headerSize, networkDimensions, list, region, col, row, depth, sourceRegion, sourceDepth)
        
    % Get afferent synapse matrix
    weightBox = afferentSynapseMatrixForNeuron(fileID, headerSize, networkDimensions, list, region, col, row, depth, sourceRegion, sourceDepth);
    dimension = length(weightBox);
    
    % Plot
    % figure();
    surf(weightBox);
    
    shading interp
    lighting phong
    view([90,90])
    axis([1 dimension 1 dimension 0 0.2])

    hold on
    axis square
    axis on   