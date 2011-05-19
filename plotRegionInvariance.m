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
%  standalone: whether gui should be shown (i.e standalone == true)
%  region: region to plot, V1 = 1
%  depth: region depth to plot
%  row: neuron row
%  col: neuron column
%  
%  Output========
%

% 'D:\Oxford\Work\Projects\VisBack\Simulations\1Object\1Epoch\firingRate.dat'

function [fig, maxFullInvariance, maxMean] = plotRegionInvariance(filename, region, depth)

    % Import global variables
    declareGlobalVars();

    % Open file
    fileID = fopen(filename);
    
    % Read header
    [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(fileID);
    
    % Fill in missing arguments    
    if nargin < 3,
        depth = 1;                                  % pick top layer
        
        if nargin < 2,
            region = length(networkDimensions);     % pick last region
        end
    end
    
    if region < 2,
        error('Region is to small');
    end
    
    numEpochs = historyDimensions.numEpochs;
    numTransforms = historyDimensions.numTransforms;
    regionDimension = networkDimensions(region).dimension;
    
    % Allocate data structure
    invariance = zeros(regionDimension, regionDimension, historyDimensions.numObjects);
    bins = zeros(numTransforms + 1,1);
    
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
    
    floatError = 0.1;
    
    % Iterate objects
    for o = 1:historyDimensions.numObjects,           % pick all objects,
        
        % Zero out from last object
        invariance = 0*invariance;
        bins = 0*bins;
        
        % Iterate region depth
        %if(standalone),
        %    h = waitbar(0,'Loading Neuron History...');
        %end
        
        for row = 1:regionDimension,

            %if(standalone),
            %    waitbar(r/regionDimension,h); % putting progress = ((r-1)*dimension + c)/dimension^2 in inner loop makes it to slow
            %end
            
            for col = 1:regionDimension,

                % Get history array
                activity = neuronHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, numEpochs); % pick last epoch

                % Count number of non zero elements
                count = length(find(activity(historyDimensions.numOutputsPrTransform, :, o, numEpochs) > floatError));

                % Save in proper bin and in invariance surface
                invariance(row, col, o) = count;
                bins(count + 1) = bins(count + 1) + 1;
            end
        end
        
        %if(standalone),
        %    close(h);
        %end
        
        b = bins(2:length(bins));
        
        subplot(historyDimensions.numObjects+1, 1,1);
        plot(b);
        hold all;
        
        % Update max values
        maxFullInvariance = max(maxFullInvariance, b(numTransforms)); % The latter is the number of neurons that are fully invariant
        maxMean = max(maxMean, dot((b./(sum(b))),1:numTransforms)); % The latter is the mean level of invariance
    end
    
    title(filename);
    
    % Iterate objects
    for o = 1:historyDimensions.numObjects,           % pick all objects,
        
        subplot(historyDimensions.numObjects+1, 1, o+1);
        imagesc(invariance(:, :, o));                    
        colorbar
        axis square;
    end
    
    maxFullInvariance
    maxMean
    
    fclose(fileID);
    