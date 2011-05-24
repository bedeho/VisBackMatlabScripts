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

    INFO_ANALYSIS_FOLDER = '/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/InfoAnalysis';

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
        bins = 0*bins;
        
        for row = 1:regionDimension,

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
        
        b = bins(2:length(bins));
        
        %subplot(historyDimensions.numObjects+1, 1,1);
        subplot(3, 1, 1);
        plot(b);
        hold all;
        
        % Update max values
        maxFullInvariance = max(maxFullInvariance, b(numTransforms)); % The latter is the number of neurons that are fully invariant
        maxMean = max(maxMean, dot((b./(sum(b))),1:numTransforms)); % The latter is the mean level of invariance
    end
    
    title(filename);
    
    fclose(fileID);
    
    % Convert firingRate file into NetStates file
    netStatesFilename = convertToNetstates(filename);
    
    % Copy NetStates1 to info analysis folder
    copyfile(netStatesFilename, [INFO_ANALYSIS_FOLDER '/NetStates1'])

    % Change present working directory to infoanalysis folder, and run analysis there
    initialPwd = pwd;
    cd(INFO_ANALYSIS_FOLDER);   % We have to be in the working directory of infoanalysis and run it from there, otherwise it will not find its file
    [status, result] = system(['./infoanalysis -f 1 -b 10 -l ' num2str(region - 2)]);
    
    if status,
        result
        return;
    end
    
    % Load single cell & plot
    system(['./infoplot -s -f 1 -x ' num2str(regionDimension*regionDimension) ' -y 3 -z -0.5 -l ' num2str(region - 2) ' -n "trace" -t "Single cell Analysis"']);
    
    if status,
        result
        %return;
    end
    
    load data0s;
    subplot(3, 1, 2);
    plot(data0s(:,2));
    title('Single cell');
    
    % Load multiple cell & plot
    system(['./infoplot -m -f 1 -x ' num2str(regionDimension*regionDimension) ' -y 3 -z -0.5 -l ' num2str(region - 2) ' -n "trace" -t "Single cell Analysis"']);
    
    if status,
        result
        %return;
    end
    
    load data0m;
    subplot(3, 1, 3);
    plot(data0m(:,2));
    title('Multiple cell');

    % Iterate objects
    %for o = 1:historyDimensions.numObjects,           % pick all objects,
    %    
    %    subplot(historyDimensions.numObjects+1, 1, o+1);
    %    imagesc(invariance(:, :, o));                    
    %    colorbar
    %    colormap(jet(historyDimensions.numTransforms + 1));
    %end
    
    maxFullInvariance
    maxMean
    
    cd(initialPwd);
    
    