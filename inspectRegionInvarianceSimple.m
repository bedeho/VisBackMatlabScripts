
function inspectRegionInvarianceSimple(filename, region, depth)

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

    fig = figure();

    floatError = 0.1;

    activity = regionHistory(fileID, historyDimensions, neuronOffsets, networkDimensions, region, depth, numEpochs);
    
    w = activity(historyDimensions.numOutputsPrTransform, :, :, numEpochs, :, :) > floatError;
    p = squeeze(sum(squeeze(sum(squeeze(w)))));
    imagesc(p');
    colorbar

    title(filename);
    
    %mark = ['r', ':b', 'g--']; 
    %set(0,'DefaultAxesLineStyleOrder',{'-*','-s','-o'})

    % Capture mouse click
    while 1
        
        figure(fig);
        
        v = round(ginput(1));
        row = v(2);
        col = v(1);
        
        str = ['row: ' int2str(row) ', col: ' int2str(col)]
        
        figure();
        
        for o=1:historyDimensions.numObjects,
            
            activity = neuronHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, numEpochs); % pick last epoch
            plot(activity(historyDimensions.numOutputsPrTransform, :, o, numEpochs)); % , mark(o)
            hold all;
        end
        
        axis([1 numTransforms -0.1 1.1]);
        
        
        title(str);
    end

    