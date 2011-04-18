
% PLOT HISTORY
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

function plotNeuronHistory(filename, region, depth, row, col, objects, transforms, epochs, ticks)

    % Import global variables
    declareGlobalVars();

    % Open file
    fileID = fopen(filename);
    
    % Read header
    [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(fileID)
    
    % Fill in missing arguments, 
    % we always choose last value as default
    if nargin < 9,
        ticks = historyDimensions.numOutputsPrTransform;

        if nargin < 8,
            epochs = historyDimensions.numEpochs;

            if nargin < 7,
                transforms = historyDimensions.numTransforms;

                if nargin < 6,
                    objects = historyDimensions.numObjects;
                end
            end
        end
    end

        
    % Get history array
    activity = history(fileID, historyDimensions, neuronOffsets, region, depth, row, col, objects, transforms, epochs, ticks);
    
    % Make title with all the good stuff encoded
    title('Single Cell Invariance Plot');
    
    % Plot
    for ti=ticks,
        for e=epochs,
            figure();
            for o=objects,
                 %for t=transforms,
                    plot(activity(:,o,ti,e));
                    title('plot');
                    hold on;
                 %end
            end
            axis([1 length(transforms)]) %  0 0.3
        end
    end
