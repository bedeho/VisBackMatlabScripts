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
%  Output========
%

function inspectRegionInvariance(folder, networkFile)

    % Import global variables
    declareGlobalVars();

    % Fill in missing arguments    
    if nargin < 2,
        networkFile = '/firingRate.dat';
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Invariance Plots
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Open files
    invarianceFileID = fopen([folder networkFile]);
    
    % Read header
    [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(invarianceFileID);
    
    % Setup vars
    numRegions = length(networkDimensions);
    depth = 1;
    numEpochs = historyDimensions.numEpochs;
    numTransforms = historyDimensions.numTransforms;
    numObjects = historyDimensions.numObjects;
    floatError = 0.1;
    
    % Allocate datastructure
    regionActivity = cell(numRegions - 1);
    axisVals = zeros(numRegions, 3);
    
    % Iterate regions to
    % 1) Do initial plots
    % 2) Setup callbacks for mouse clicks
    for r=2:numRegions,
        
        % Get region activity
        regionDimension = networkDimensions(r).dimension;
        regionActivity{r - 1} = regionHistory(invarianceFileID, historyDimensions, neuronOffsets, networkDimensions, r, depth, numEpochs);
        
        % Save axis
        axisVals(r-1,1) = subplot(numRegions, 3, 3*(r-2) + 1);

        % Plot invariance historgram for region
        for o=1:numObjects,
            
            w = regionActivity{r - 1}(historyDimensions.numOutputsPrTransform, :, o, numEpochs, :, :);
            q = reshape(squeeze(sum(w > floatError)), [1 regionDimension*regionDimension]); %sum goes along first non singleton dimension, so it skeeps all our BS 1dimension
            regionHistogram = hist(q,1:(numTransforms+1)); % One extra for the 0 bucket
            plot(regionHistogram(2:(numTransforms+1)));
            hold all;
        end
        
        axis tight;
        %hold;
        
        % Save axis
        axisVals(r-1, 2) = subplot(numRegions, 3, 3*(r-2) + 2);
        
        % Plot region invarinceCount
        w = regionActivity{r - 1}(historyDimensions.numOutputsPrTransform, :, :, numEpochs, :, :);
        invarinceCount = squeeze(sum(sum(w > floatError))); %sum goes along first non singleton dimension, so it skeeps all our BS 1dimension
        im = imagesc(invarinceCount');
        colorbar
        colormap(jet(numTransforms + 1));
        
        set(im, 'ButtonDownFcn', {@invarianceCallBack, r}); %@{invarianceCallBack, r}
    end
    
    fclose(invarianceFileID);
    
    % Setup blank present cell invariance plot
    axisVals(numRegions, [1 3]) = subplot(numRegions, 3, [3*(numRegions-1) + 1, 3*(numRegions-1) + 3]);
    plot(0);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Weight Plots
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CALLBACKS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function invarianceCallBack(varargin)
        
        % Extract region,row,col
        region = varargin{3};
        %rdim = networkDimensions(region).dimension;
        pos=get(axisVals(region-1, 2),'CurrentPoint');
        
        row = imagescClick(pos(1, 2));
        col = imagescClick(pos(1, 1));
        
        disp(['You clicked X:' num2str(col) ', Y:', num2str(row)]);
        
        % Populate invariance plot
        subplot(numRegions, 3, [3*(numRegions-1) + 1, 3*(numRegions-1) + 3]);
        
        for obj=1:numObjects,
            
            w2 = regionActivity{region - 1}(historyDimensions.numOutputsPrTransform, :, obj, numEpochs, row, col);
            q2 = w2 > floatError;
            plot(q2);
            hold all;
        end  
        
        axis([1 numTransforms -0.1 1.1]);
        
        hold;
    end
    
    function connectivityCallBack()
    end

    function [res] = imagescClick(i)

        if i < 0.5
            res = 1;
        else
            res = round(i);
        end
    end
    
end