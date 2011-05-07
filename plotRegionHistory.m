%
% platRegionHistory.m
% VisBack
%
% Created by Bedeho Mender on 29/04/11.
% Copyright 2011 OFTNAI. All rights reserved.
%
% Input=========
% filename: filename of weight file
% region: region to plot
% depth: region depth to plot
% epcohs: vector of regions to plot [e1,e2,...]
% Output========
% Plots one 2d activity plot of region/depth pr. transform in each figure and one figure for each epoch, always 
% picks last outputted time step of every transform

function plotRegionHistory(filename, region, depth, epochs)

    % Import global variables
    declareGlobalVars();

    % Open file
    fileID = fopen(filename);
    
    % Read header
    [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(fileID)
    
    % Fill in missing arguments
    if nargin < 4,
        epochs = 1:historyDimensions.numEpochs;             % pick all epochs
    end
    
    transforms = 1:historyDimensions.numTransforms;
    dimension = networkDimensions(region).dimension;
    
    % Get history array
    activity = regionHistory(fileID, historyDimensions, neuronOffsets, networkDimensions, region, depth, max(epochs));
    
    % Plot
    plotDim = ceil(sqrt(length(transforms)));
    
    for e=1:length(epochs),
        for o=1:historyDimensions.numObjects,
            
            figure();
            title(['Epoch: ', num2str(epochs(e)), ', Object:', num2str(o), ', Tick: LAST']);
             for t=1:length(transforms),

                subplot(plotDim,plotDim,t);
                surf(activity(:,:,historyDimensions.numOutputsPrTransform, t, o, e));
                title(['Transform:', num2str(t)]);
                hold on;
                
                %shading interp
                lighting phong
                view([90,90])
                axis([1 dimension 1 dimension]) %  0 0.3

             end
        end
    end 
   
