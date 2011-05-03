%
%  plotRegionInvariance.m
%  VisBack
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

% PLOT REGION INVARIANCE
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

function [fig] = plotRegionInvariance(filename, progressbar, region, depth)

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
        
    tick = historyDimensions.numOutputsPrTransform;     % pick last output
    epoch = historyDimensions.numEpochs;                % pick last epoch
    transforms = 1:historyDimensions.numTransforms;     % pick all transforms
    
    % detect if -nodisplay option is set
    % http://www.mathworks.com/matlabcentral/newsreader/view_thread/136261
    %s = get(0,'Screensize');
    
    %{
    if s(3) == 1 && s(4) == 1,
        progressbar = false;
    else
        progressbar = true;
    end
    %}
    
    
    
    fig = figure();
    
    set(0,'DefaultAxesColorOrder',[1 0 0;0 1 0;0 0 1],'DefaultAxesLineStyleOrder','-|--|:');
    
    % Iterate objects
    for o=1:1 %historyDimensions.numObjects,
        
        % Zero out from last object
        invariance = 0*invariance;
        bins = 0*bins;
        
        % Iterate region depth
        
        if(progressbar),
            h = waitbar(0,'Loading Neuron History...');
        end
        
        for row=1:regionDimension,

            if(progressbar),
                waitbar(row/regionDimension,h); % putting progress = ((r-1)*dimension + c)/dimension^2 in inner loop makes it to slow
            end
            
            for col=1:regionDimension,

                % Get history array
                activity = neuronHistory(fileID, historyDimensions, neuronOffsets, region, depth, row, col, o, transforms, epoch, tick);

                % count number of non zero elements
                %count = nnz(activity(:,1,1,1));
                count = sigmoidFixer(activity(:,1,1,1));
                %activity(:,1,1,1)
                %count

                % save in proper bin and in invariance surface
                invariance(row,col) = count;
                bins(count + 1) = bins(count + 1) + 1;
            end
        end

        if(progressbar),
            close(h);
        end

        bins(1) = 0;
        subplot(2,1,1);
        plot(bins);
        hold on;
        
        %bins
        
        subplot(2,1,2);
        surf(invariance);                    

        lighting phong
        view([90,90])
        hold on
    end
    
    title(filename);
    
    format('longE');
    v = neuronHistory(fileID, historyDimensions, neuronOffsets, 5, 1, 1, 1, 70, transforms, epoch, tick)
    figure;
    plot(v);
    
    function [count] = sigmoidFixer(v)
        
        count = 0;
        for i=1:length(v);
            if v(1) > 0.1,
                count = count +1;
            end
        end