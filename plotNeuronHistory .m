
% PLOT HISTORY
% Input=========
% filename: filename of weight file
% region: neuron region, V1 = 1
% object:
% transform:
% epoch:
% tick:
% depth: neuron depth
% row: neuron row
% col: neuron column
% Output========
%
% 'D:\Oxford\Work\Projects\VisBack\Simulations\1Object\1Epoch\firingRate.dat'

function plotRegionHistory(filename, region, object, transform, epoch, tick, depth, row, col)

    % Import global variables
    declareGlobalVars();

    % Open file
    fileID = fopen(filename);
    
    % Read header
    [networkDimensions, numEpochs, numObjects, numTransforms, numOutputsPrTransform, headerSize, neuronOffsets] = loadHistoryHeader(fileID)
    
    % Setup plotting ranges
    regionDimension = networkDimensions(region).dimension;
    
    % No cell provided 
    if nargin < 9
        rowRange = 1:regionDimension;
        colRange = 1:regionDimension;
        depthRange = 1;
    else
        rowRange = row:row;
        colRange = col:col;
        depthRange = depth;
    end
    
    

    
    % Call plot routine
    neuronCounter = 1;
    for i=rowRange, % Region row
        for j=colRange, % Region col
            for d=depthRange, % Source region depth

                if nargin < 4
                    subplot(regionDimension, regionDimension, neuronCounter);
                end
                
                neuronCounter = neuronCounter + 1;

                % Get afferent synapse matrix
                weightBox = afferentSynapseMatrix(fileID, headerSize, networkDimensions, list, region, depth, i, j, sourceRegion, d);

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

