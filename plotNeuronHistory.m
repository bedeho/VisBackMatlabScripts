
% PLOT NEURON HISTORY
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
    if nargin < 9,
        ticks = historyDimensions.numOutputsPrTransform;        % pick last output

        if nargin < 8,
            epochs = 1:historyDimensions.numEpochs;             % pick all epochs

            if nargin < 7,
                transforms = 1:historyDimensions.numTransforms; % pick all transforms

                if nargin < 6,
                    objects = 1:historyDimensions.numObjects;   % pick all objects
                end
            end
        end
    end

        
    % Get history array
    activity = neuronHistory(fileID, historyDimensions, neuronOffsets, region, depth, row, col, objects, transforms, epochs, ticks);
    
    % Plot
    for ti=ticks,
        for e=epochs,
            figure();
            for o=objects,
                 %for t=transforms,
                    plot(activity(:,o,ti,e));
                    title(['Epoch: ', num2str(e), ', Object:', num2str(o), ', Tick:', num2str(ti)]);
                    hold on;
                 %end
            end
        end
    end
