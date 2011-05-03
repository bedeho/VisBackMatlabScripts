%
%  plotRegionInvariance.m
%  VisBack
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  PLOT REGION INVARIANCE
%  Input=========
%  filename: filename of weight file
%  region: region to plot, V1 = 1
%  depth: region depth to plot
%  row: neuron row
%  col: neuron column
%  objects:
%  transforms:
%  epochs:
%  ticks:
%  Output========
%
% 'D:\Oxford\Work\Projects\VisBack\Simulations\1Object\1Epoch\firingRate.dat'

function [fig, maxFullInvariance, maxMean] = plotRegionInvariance(filename, standalone, region, depth)

    % Import global variables
    declareGlobalVars();

    % Open file
    fileID = fopen(filename);
    
    % Read header
    [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(fileID)
    
    % Fill in missing arguments, 
    if nargin < 4,
        depth = 1;                                  % pick top layer
        
        if nargin < 3,
            region = length(networkDimensions);     % pick last region
        end
    end
    
    % Region dimension
    numTransforms = historyDimensions.numTransforms;
    regionDimension = networkDimensions(region).dimension;
    
    % Allocate data structure
    invariance = zeros(regionDimension);
    bins = zeros(numTransforms + 1,1);
    
    % Iteration vectors
    tick = historyDimensions.numOutputsPrTransform;     % pick last output
    epoch = historyDimensions.numEpochs;                % pick last epoch
    transforms = 1:historyDimensions.numTransforms;     % pick all transforms
    objects = 1:historyDimensions.numObjects;           % pick all objects
    row = 1:regionDimension;
    col = 1:regionDimension;
    
    % Setup Max vars
    maxFullInvariance = 0;
    maxMean = 0;
    
    % detect if -nodisplay option is set
    % http://www.mathworks.com/matlabcentral/newsreader/view_thread/136261
    %{ 
    s = get(0,'Screensize');
    if s(3) == 1 && s(4) == 1,
        progressbar = false;
    else
        progressbar = true;
    end
    %}
    
    fig = figure();
    
    % Iterate objects
    for o = objects,
        
        % Zero out from last object
        invariance = 0*invariance;
        bins = 0*bins;
        
        % Iterate region depth
        if(standalone),
            h = waitbar(0,'Loading Neuron History...');
        end
        
        for r = row,

            if(standalone),
                waitbar(r/regionDimension,h); % putting progress = ((r-1)*dimension + c)/dimension^2 in inner loop makes it to slow
            end
            
            for c = col,

                % Get history array
                activity = neuronHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, r, c, o, transforms, epoch, tick);

                % Count number of non zero elements
                count = length(find(activity(:,1,1,1) > 0.1));
                %activity(:,1,1,1)
                %count

                % Save in proper bin and in invariance surface
                invariance(r, c) = count;
                bins(count + 1) = bins(count + 1) + 1;
            end
        end

        if(progressbar),
            close(h);
        end
        
        b = bins(2:length(bins));
        
        % subplot(1,1,1);
        plot(b);
        hold all;
        
        %subplot(2,1,o+1);
        %surf(invariance);                    
        %lighting phong
        %view([90,90])
        
        % Update max values
        maxFullInvariance = max(maxFullInvariance, b(historyDimensions.numTransforms)); % The latter is the number of neurons that are fully invariant
        maxMean = max(maxMean, (b./(sum(b))).*transforms); % The latter is the mean level of invariance
    end
    
    title(filename);
    
    maxFullInvariance
    maxMean
    