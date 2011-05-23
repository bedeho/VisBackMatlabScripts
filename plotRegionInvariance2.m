
function plotRegionInvariance2(filename, region, depth)

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
    %regionDimension = networkDimensions(region).dimension;

    fig = figure();

    floatError = 0.1;

    activity = regionHistory(fileID, historyDimensions, neuronOffsets, networkDimensions, region, depth, numEpochs);
    
    w = activity(historyDimensions.numOutputsPrTransform, :, :, numEpochs, :, :) > floatError;
    p = squeeze(sum(squeeze(sum(squeeze(w)))));
    imagesc(p');
    colorbar

    title(filename);
    
    mark = ['+:', 's-', 'o--']; 
    

    % Capture mouse click
    while 1
        
        figure(fig);
        
        v = round(ginput(1));
        row = v(2);
        col = v(1);
        
        str = ['row: ' int2str(row) ', col: ' int2str(col)]
        
        figure();
        
        set(0,'DefaultAxesLineStyleOrder',{'-*',':','o'})
        
        for o=1:historyDimensions.numObjects,
            
            activity = neuronHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, numEpochs); % pick last epoch
            plot(activity(historyDimensions.numOutputsPrTransform, :, o, numEpochs) , mark(o)); %
            hold all;
        end
        
        axis([1 numTransforms -0.1 1.1]);
        
        
        title(str);
    end
    
    
%    %for row = 1:regionDimension,
%    %    for col = 1:regionDimension,
%
%            % Get history array
%            activity = neuronHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, numEpochs); % pick last epoch
%
%            % Count number of non zero elements
%            neuronCount(row,col) = length(find(activity(historyDimensions.numOutputsPrTransform, :, :, numEpochs) > floatError));
%        end
%    end

    