
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
    
    % Call plot routine
    figure();
    
    % If no source region is provided, then the one just prior to region is
    % chosen
    if nargin < 6
        sourceRegion = region - 1;
    end
    
    if nargin < 2 % If no cell was chosen, then plot all cells in region
    
    elseif nargin < 7 % If no source depth is chosen, then all are plotted
        for d = 1:networkDimensions(sourceRegion).depth
            plotMatrix(fileID, headerSize, networkDimensions, list, region, col, row, depth, sourceRegion, d);
            hold on;
        end
    else
        plotMatrix(fileID, headerSize, networkDimensions, list, region, col, row, depth, sourceRegion, sourceDepth);
    end
    
    dimension = networkDimensions(sourceRegion).dimension;
    
    shading interp
    lighting phong
    view([90,90])
    axis([1 dimension 1 dimension 0 0.2])
    axis on
    
% Do we need this, maybee reinject
function plotMatrix(fileID, headerSize, networkDimensions, list, region, col, row, depth, sourceRegion, sourceDepth)
        
    % Get afferent synapse matrix
    weightBox = afferentSynapseMatrixForNeuron(fileID, headerSize, networkDimensions, list, region, col, row, depth, sourceRegion, sourceDepth);
    
    % Plot
    surf(weightBox);
 