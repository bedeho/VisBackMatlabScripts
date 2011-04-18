
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
    
    % Fill in missing arguments
    if nargin < 9,
        tick = 1; % choose first tick as default

        if nargin < 8,
            epoch = 1; % choose first epoch as default

            if nargin < 7,
                transform = 1; % choose frist transform as default

                if nargin < 6,
                    object = 1; % choose first object as default
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
                 for t=transforms,
                    plot(activity);
                    title('plot');
                    hold on;
                 end
            end
            axis([1 length(transforms)]) %  0 0.3
        end
    end
