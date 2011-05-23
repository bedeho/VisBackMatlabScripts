%
%  inspectRegionInvariance.m
%  VisBack
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  PLOT REGION INVARIANCE
%  Input=========
%  filename: filename of weight file
%  standalone: whether gui should be shown (i.e standalone == true)
%  region: region to plot, V1 = 1
%  depth: region depth to plot
%  row: neuron row
%  col: neuron column
%  
%  Output========
%

% 'D:\Oxford\Work\Projects\VisBack\Simulations\1Object\1Epoch\firingRate.dat'

function inspectRegionInvariance(folder, object, networkFile)

    % Import global variables
    declareGlobalVars();

    % Fill in missing arguments    
    if nargin < 3,
        
        networkFile = '/TrainedNetwork.txt';
        
        if nargin < 2,
            disp('missing arguments!');
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Open files
    invarianceFileID = fopen([folder '/firingRate.dat']);
    
    % Read header
    [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(invarianceFileID);
    
    % Setup vars
    numRegions = length(networkDimensions);
    depth = 1;
    numEpochs = historyDimensions.numEpochs;
    numTransforms = historyDimensions.numTransforms;
    floatError = 0.1;
    
    % Allocate data structure
    invarianceProfile = cell(numRegions - 1);
    invarinceCount = cell(numRegions - 1);
    regionHistogram = zeros(numTransforms + 1,numRegions - 1);
    axisVals = zeros(numRegions, 3);
    
    % Iterate regions
    for r=2:numRegions,
        
        % Dimension of present region
        regionDimension = networkDimensions(r).dimension;
        
        % Allocate space for invariance vectors
        invarianceProfile{r - 1} = zeros(numTransforms, regionDimension, regionDimension);
        invarinceCount{r - 1} = zeros(regionDimension, regionDimension);
        
        for row = 1:regionDimension,
            for col = 1:regionDimension,

                % Get history array
                activity = neuronHistory(invarianceFileID, networkDimensions, historyDimensions, neuronOffsets, r, depth, row, col, numEpochs); % pick last epoch

                % Save invariance plot for cell
                invariance = activity(historyDimensions.numOutputsPrTransform, :, object, numEpochs);
                invarianceProfile{r - 1}(:, row, col) = invariance;
                
                % Save invariance count for cell
                count = length(find(invariance > floatError));
                invarinceCount{r - 1}(row, col) = count;

                % Save in proper bin
                regionHistogram(count + 1, r - 1) = regionHistogram(count + 1, r - 1) + 1;
            end
        end
        
        % Plot region histogram
        axisVals(r-1,1) = subplot(numRegions,3, 3*(r-2) + 1);
        plot(regionHistogram(:, r - 1));
        axis tight
        
        % Plot region invarinceCount
        axisVals(r-1,2) = subplot(numRegions,3, 3*(r-2) + 2);
        imagesc(invarinceCount{r - 1}(:, :));
        colorbar
        colormap(jet(numTransforms + 1));
    end
    
    fclose(invarianceFileID);
    
    % Setup blank present cell invariance plot
    axisVals(numRegions,[1 3]) = subplot(numRegions,3, [3*(numRegions-1) + 1, 3*(numRegions-1) + 3]);
    plot(0)
    
    %Start listening to mouse clicks
    
    % REALLY FUNKY bad!
    while 1
        k = waitforbuttonpress;
        v = round(ginput(1));
        %['row: ' int2str(v(2)) ', col: ' int2str(v(1))]
        
        
    end   
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    