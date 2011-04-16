
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

function plotAfferentSynapses(filename, region, depth, row, col, sourceRegion, sourceDepth)

    % Import global variables
    declareGlobalVars();

    % Open file
    fileID = fopen(filename);
    
    % Read header
    [networkDimensions, list, headerSize] = loadWeightFileHeader(fileID);
    
    % If no source region is provided, then the one just prior to region is
    % chosen
    if nargin < 6
        sourceRegion = region - 1;
    end
    
    % Setup plotting ranges
    regionDimension = networkDimensions(region).dimension;
    % regionDepth = networkDimensions(region).depth;
    
    if nargin < 3
        depth = 1;
    end
    
    % If no planar cordinate of cell are provided, 
    if nargin < 4
        rowRange = 1:4; %1:regionDimension;
        colRange = 1:4; % 1:regionDimension;
    else
        rowRange = row:row;
        colRange = col:col;
    end
    
    % If no source depth is chosen, then all are plotted
    if nargin < 7 
        depthRange = 1:networkDimensions(sourceRegion).depth;
    else
        depthRange = sourceDepth:sourceDepth;
    end
    
    
    % Call plot routine
    figure();

    neuronCounter = 1;
    for i=rowRange, % Region row
        for j=colRange, % Region col
            for d=depthRange, % Source region depth

                if nargin < 4
                    subplot(regionDimension, regionDimension, neuronCounter);
                end
                
                neuronCounter = neuronCounter + 1;

                % Get afferent synapse matrix
                weightBox = afferentSynapseMatrixForNeuron(fileID, headerSize, networkDimensions, list, region, depth, i, j, sourceRegion, d);

                % Plot
                surf(weightBox);
                hold on;
                % pause;
            end
        end
    end
    
    shading interp
    lighting phong
    view([90,90])
    %axis([1 regionDimension 1 regionDimension]) %  0 0.3
    %axis on

