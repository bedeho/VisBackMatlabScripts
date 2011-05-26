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
            regionHistogram = hist(q,1:numTransforms);
            plot(regionHistogram(2:numTransforms));
            axis tight
            hold all
        end
        
        % Save axis
        axisVals(r-1, 2) = subplot(numRegions, 3, 3*(r-2) + 2);
        
        % Plot region invarinceCount
        w = regionActivity{r - 1}(historyDimensions.numOutputsPrTransform, :, :, numEpochs, :, :);
        invarinceCount = squeeze(sum(sum(w > floatError))); %sum goes along first non singleton dimension, so it skeeps all our BS 1dimension
        im = imagesc(invarinceCount);
        colorbar
        colormap(jet(numTransforms + 1));
        
        set(im, 'ButtonDownFcn', {@invarianceCallBack, r}); %@{invarianceCallBack, r}
    end
    
    fclose(invarianceFileID);
    
    % Setup blank present cell invariance plot
    axisVals(numRegions, [1 3]) = subplot(numRegions, 3, [3*(numRegions-1) + 1, 3*(numRegions-1) + 3]);
    plot(0);
    
    %(timestep, transform, object, epoch , row, col)

    
    function invarianceCallBack(varargin)
        
        % Extract region,row,col
        region = varargin{3};
        pos=get(axisVals(region-1, 2),'CurrentPoint');
        
        row = imageScClick(pos(1, 2));
        col = imageScClick(pos(1, 1));
        
        disp(['You clicked X:' num2str(col) ', Y:', num2str(row)]);
        
        % Populate invariance plot
        for obj=1:numObjects,
            
            w2 = regionActivity{r - 1}(historyDimensions.numOutputsPrTransform, :, o, numEpochs, :, :);
            %q2 = reshape(squeeze(sum(w > floatError)), [1 regionDimension*regionDimension]); %sum goes along first non singleton dimension, so it skeeps all our BS 1dimension
            %regionHistogram = hist(q,1:numTransforms);
            %plot(regionHistogram(2:numTransforms));
            %axis tight
            %hold all
        end
        
        
        
        
    end
    

    function connectivityCallBack()
    end

    function [res] = imageScClick(i)

        if i < 0.5
            res = 1;
        else
            res = round(i);
        end
    end
    
end


    
    %{
    
    
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
    %}
    
    %Start listening to mouse clicks
    
    %{
    subplot(2,1,1);
    imagesc(rand(5));

    ax = subplot(2,1,2);
    t= imagesc(rand(10));

    set(t,'ButtonDownFcn',@mytestcallback) % WindowButtonDownFcn

    function mytestcallback(hObject,~)
        pos=get(ax,'CurrentPoint');
        row = rround(pos(1, 2));
        col = rround(pos(1, 1));

        disp(['You clicked X:' num2str(col) ', Y:', num2str(row)]);

        function [res] = rround(i)

            if i < 0.5
                res = 1;
            else
                res = round(i);
            end
        end
    end
 
    %}
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    