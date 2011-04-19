
% PLOT REGION STABILITY HISTORY
% Input=========
% filename: filename of weight file
% region: region to plot, V1 = 1
% depth: region depth to plot
% row: neuron row
% col: neuron column
% objects:
% transforms:
% epochs:
% ticks:
% Output========
%
% 'D:\Oxford\Work\Projects\VisBack\Simulations\1Object\1Epoch\firingRate.dat'

function [] = plotRegionStability(filename, region, depth, objects, epochs, ticks)

   % Import global variables
    declareGlobalVars();

    % Open file
    fileID = fopen(filename);
    
    % Read header
    [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(fileID)
    
    % Fill in missing arguments, 
    if nargin < 6,
        ticks = historyDimensions.numOutputsPrTransform;        % pick last output

        if nargin < 5,
            epochs = 1:10;             % pick all epochs

            if nargin < 4,
                objects = 1:historyDimensions.numObjects;       % pick all transforms

                if nargin < 3,
                    depth = 1;                                  % pick first layer
                end
            end
        end
    end
    
    transforms = 1:historyDimensions.numTransforms;
    regionDimension = networkDimensions(region).dimension;
    
    % Get history array
    activity = regionHistory(fileID, historyDimensions, neuronOffsets, networkDimensions, region, depth, objects, transforms, epochs, ticks);
    
    % Plot
    plotDim = ceil(sqrt(length(transforms)));
    
    oldActivity = cell(transform, objects, 
    
    for ti=1:length(ticks),
        for e=1:length(epochs),
            figure();
            title(['Tick:', num2str(ti), ', Epoch: ', num2str(e)]);
            
            for t=1:length(transforms),
                subplot(plotDim,plotDim,t);

                for o=1:length(objects),

                end

                surf(activity(:,:,t,o,ti,e));
                title(['Transform:', num2str(t)]);
                hold on;
                lighting phong;
                view([90,90]);
                axis([1 regionDimension 1 regionDimension]); %  0 0.3

            end
        end
    end