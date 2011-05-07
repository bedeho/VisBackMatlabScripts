%
% platNetworkHistory.m
% VisBack
%
% Created by Bedeho Mender on 29/04/11.
% Copyright 2011 OFTNAI. All rights reserved.
%
% PLOT REGION HISTORY
% Input=========
% filename: filename of weight file
% region: region to plot, V1 = 1
% depth: region depth to plot
% row: neuron row
% col: neuron column
% objects:
% epochs:
% ticks:
% Output========
%

function plotNetworkHistory(filename, region, depth, objects, epochs)

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
            epochs = 1:historyDimensions.numEpochs;             % pick all epochs

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
    
    for ti=1:length(ticks),
        for e=1:length(epochs),
            for o=1:length(objects),
                figure();
                title(['Epoch: ', num2str(e), ', Object:', num2str(o), ', Tick:', num2str(ti)]);
                 for t=1:length(transforms),
                    
                    subplot(plotDim,plotDim,t);
                    surf(activity(:,:,t,o,ti,e));
                    title(['Transform:', num2str(t)]);
                    hold on;
                        %shading interp
                    lighting phong
                    view([90,90])
                    axis([1 regionDimension 1 regionDimension]) %  0 0.3

                 end
            end
        end
    end