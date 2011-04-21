
% PLOT REGION HISTORY
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

function plotRegionHistory(filename, region, depth, objects, epochs, ticks)

    % Import global variables
    declareGlobalVars();

    % Open file
    fileID = fopen(filename);
    
    % Read header
    [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(fileID)
    
    % Fill in missing arguments, 
    if nargin < 6,
        ticks = historyDimensions.numOutputsPrTransform;        % pick last output

        if nargin < 5,
            epochs = 1:historyDimensions.numEpochs;             % pick all epochs

            if nargin < 4,
                objects = 1:historyDimensions.numObjects;       % pick all transforms

                if nargin < 3,
                    depth = 1;                                  % pick first layer
                end
            end
        end
    end
    
    transforms = 1:historyDimensions.numTransforms;
    regionDimension = networkDimensions(region).dimension;
    
    % Get history array
    activity = regionHistory(fileID, historyDimensions, neuronOffsets, networkDimensions, region, depth, objects, transforms, epochs, ticks);
    
    % Plot
    
    
    plotDim = ceil(sqrt(length(transforms)));
    
    for ti=1:length(ticks),
        for e=1:length(epochs),
            for o=1:length(objects),
                figure();
                title(['Epoch: ', num2str(e), ', Object:', num2str(o), ', Tick:', num2str(ti)]);
                 for t=1:length(transforms),
                    
                    subplot(plotDim,plotDim,t);
                    surf(activity(:,:,t,o,ti,e));
                    title(['Transform:', num2str(t)]);
                    hold on;
                        %shading interp
                    lighting phong
                    view([90,90])
                    axis([1 regionDimension 1 regionDimension]) %  0 0.3

                 end
            end
        end
    end
    

    
    
    %{
    
 
    % Call plot routine
    neuronCounter = 1;
    
    for i=rowRange, % Region row
        for j=colRange, % Region col
            for d=depthRange, % Source region depth

                if nargin < 4
                    subplot(regionDimension, regionDimension, neuronCounter);
                end
                
                neuronCounter = neuronCounter + 1;

                % Get afferent synapse matrix
                weightBox = afferentSynapseMatrix(fileID, headerSize, networkDimensions, list, region, depth, i, j, sourceRegion, d);

                % Plot
                surf(weightBox);
                                    title(['Epoch: ', num2str(e), ', Object:', num2str(o), ', Tick:', num2str(ti)]);
                hold on;
                % pause;
            end
        end
    end
    

    %axis on

    
        %function temporalPlot()

    % Dimensions of the subplot
    subplotdim = ceil(sqrt(numOutputsPrTransform));
        
    % Shows temporal response to same stimuli,
    % suitable for feedback and timea accurate models
    for o=object,
        for t=transform,
            for e=epoch,
                figure();
                plotcounter = 1;
                for ti=tick,
                %}
    
    %}
   
