
% PLOT HISTORY
% Input=========
% filename: filename of weight file
% region: neuron region, V1 = 1
% object:
% transform:
% epoch:
% tick:
% depth: region depth, d = 1 is top/first/most radial/farthest from retina
% Output========
%
% 'D:\Oxford\Work\Projects\VisBack\Simulations\1Object\1Epoch\firingRate.dat'

function plotRegionHistory(filename, region, object, transform, epoch, tick, depth)

    % Import global variables
    declareGlobalVars();

    % Open file
    fileID = fopen(filename);
    
    % Read header
    [networkDimensions, numEpochs, numObjects, numTransforms, numOutputsPrTransform, headerSize, neuronOffsets] = loadHistoryHeader(fileID)
    
    % Setup plotting ranges
    regionDimension = networkDimensions(region).dimension;
    
    % No cell provided 
    if nargin < 7
        rowRange = 1:regionDimension;
        colRange = 1:regionDimension;
        depthRange = 1;
    else
        rowRange = row:row;
        colRange = col:col;
        depthRange = depth;
    end
    
        % Fill in missing arguments
    if nargin < 10,
        depth = 1; % choose frist layer as default
        
        if nargin < 9,
            tick = 1; % choose first tick as default
            
            if nargin < 8,
                epoch = 1; % choose first epoch as default
                
                if nargin < 7,
                    transform = 1; % choose frist transform as default
                    
                    if nargin < 6,
                        object = 1; % choose first object as default
                    end
                end
            end
        end
    end
    

    
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
                hold on;
                % pause;
            end
        end
    end
    
    shading interp
    lighting phong
    view([90,90])
    %axis([1 regionDimension 1 regionDimension]) %  0 0.3
    %axis on

    
        %function temporalPlot()
        
            %{
        
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
