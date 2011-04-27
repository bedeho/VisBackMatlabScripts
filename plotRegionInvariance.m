
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

function plotRegionInvariance(filename, region, object, depth)

    % Import global variables
    declareGlobalVars();

    % Open file
    fileID = fopen(filename);
    
    % Read header
    [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(fileID)
    
    % Region dimension
    numTransforms = historyDimensions.numTransforms;
    regionDimension = networkDimensions(region).dimension;
    
    % Allocate data structure
    invariance = zeros(regionDimension,regionDimension);
    bins = zeros(numTransforms + 1);
    
    % Fill in missing arguments, 
    if nargin < 4,
        depth = 1;                                  % pick top region
        
        if nargin < 3,
            object = historyDimensions.numObjects;  % pick last object
        end
    end
    
    tick = historyDimensions.numOutputsPrTransform;     % pick last output
    epoch = historyDimensions.numEpochs;              % pick last epoch
    transforms = 1:historyDimensions.numTransforms;     % pick all transforms
    
    % Iterate region depth
    h = waitbar(0,'Loading Neuron History...');
    for row=1:regionDimension,
        
        waitbar(row/regionDimension,h); % putting progress = ((r-1)*dimension + c)/dimension^2 in inner loop makes it to slow
        
        for col=1:regionDimension,
            
            % Get history array
            activity = neuronHistory(fileID, historyDimensions, neuronOffsets, region, depth, row, col, object, transforms, epoch, tick);

            % count number of non zero elements
            count = nnz(activity(:,1,1,1));
            
            % save in proper bin and in invariance surface
            invariance(row,col) = count;
            bins(count + 1) = bins(count + 1) + 1;
        end
    end
    
    close(h);
    
    figure();
    bins(1) = 0;
    plot(bins);
    
    figure();
    surf(invariance);                    
   
    %shading interp
    lighting phong
    view([90,90])
