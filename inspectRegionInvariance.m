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
        networkFile = 'TrainedNetwork.txt';
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Invariance Plots
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Open files
    invarianceFileID = fopen([folder '/firingRate.dat']);
    
    % Read header
    [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(invarianceFileID);
    
    % Open file
    connectivityFileID = fopen([folder '/' networkFile]);

    % Read header
    [networkDimensions, neuronOffsets2] = loadWeightFileHeader(connectivityFileID);
        
    
    % Setup vars
    numRegions = length(networkDimensions);
    depth = 1;
    numEpochs = historyDimensions.numEpochs;
    numTransforms = historyDimensions.numTransforms;
    numObjects = historyDimensions.numObjects;
    floatError = 0.1;
    
    THRESHOLD = 0.15;
    
    % Allocate datastructure
    regionActivity = cell(numRegions - 1);
    axisVals = zeros(numRegions, 3);
    
    %axisVals(i,1) = axisVals(i,2) = for region V(i+1)
    %axisVals(i,3) = for region Vi
    
    fig = figure();
    
    % Iterate regions to
    % 1) Do initial plots
    % 2) Setup callbacks for mouse clicks
    for r=2:numRegions,
        
        % Get region activity
        regionDimension = networkDimensions(r).dimension;
        regionActivity{r - 1} = regionHistory(invarianceFileID, historyDimensions, neuronOffsets, networkDimensions, r, depth, numEpochs);

        % Save axis
        axisVals(r-1,1) = subplot(numRegions, 3, 3*(numRegions - r) + 1);
        
        w = regionActivity{r - 1}(historyDimensions.numOutputsPrTransform, :, :, numEpochs, :, :);
        q = reshape(sum(w > floatError), [numObjects regionDimension*regionDimension]); %sum goes along first non singleton dimension, so it skeeps all our BS 1dimension

        % Plot invariance historgram for region
        for o=1:numObjects,
            
            regionHistogram = hist(q(o,:), 0:numTransforms); % One extra for the 0 bucket
            plot(regionHistogram(2:(numTransforms+1)));
            hold all;
        end
        
        axis tight;

        % Save axis
        axisVals(r-1, 2) = subplot(numRegions, 3, 3*(numRegions - r) + 2);
        
        % Plot region invarinceCount
        w = regionActivity{r - 1}(historyDimensions.numOutputsPrTransform, :, :, numEpochs, :, :) > floatError;
        
        if numTransforms > 1,
            w = sum(w);
        end
        
        if numObjects > 1,
            w = sum(w);
        end
        
        invarinceCount = squeeze(w); %sum goes along first non singleton dimension, so it skeeps all our BS 1dimension
        im = imagesc(invarinceCount);
        colorbar
        colormap(jet(max(max(invarinceCount)) + 1)); %();
        
        axis tight;
        
        % Setup callback
        set(im, 'ButtonDownFcn', {@invarianceCallBack, r});
    end
    
    fclose(invarianceFileID);
    
    % Setup blank present cell invariance plot
    axisVals(numRegions, [1 3]) = subplot(numRegions, 3, [3*(numRegions-1) + 1, 3*(numRegions-1) + 3]);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Weight Plots
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Setup dummy weight plots
    for r=1:(numRegions-1)

        % Get region dimension
        regionDimension = networkDimensions(r).dimension;

        % Save axis
        axisVals(r, 3) = subplot(numRegions, 3, 3*(numRegions - r - 1) + 3);
        
        % Only setup callback for V2+
        if r > 1,
            im = imagesc(zeros(regionDimension));
            colorbar;

            set(im, 'ButtonDownFcn', {@connectivityCallBack, r});
        end
    end
    
    makeFigureFullScreen(fig);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CALLBACKS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function invarianceCallBack(varargin)
        
        % Extract region,row,col
        region = varargin{3};

        buttonClick = get(gcf,'SelectionType');
        
        pos=get(axisVals(region-1, 2), 'CurrentPoint');
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(region).dimension);

        disp(['You clicked R:' num2str(region) ', row:' num2str(pos(1, 2)) ', col:', num2str(pos(1, 1))]);
        disp(['You clicked R:' num2str(region) ', row:' num2str(row) ', col:', num2str(col)]);

        if strcmp(buttonClick, 'alt'), % Normal left mouse click
            plotSynapseHistory(folder, region, 1, row, col, numEpochs);
        else % Right mouse click, open synapse history
            updateInvariancePlot(region, row, col);
            updateWeightPlot(region, row, col);
        end
    end
    
    function connectivityCallBack(varargin)
        
        % Extract region,row,col
        region = varargin{3};
        
        pos = get(axisVals(region, 3), 'CurrentPoint');
        
        %row = imagescClick(pos(1, 2));
        %col = imagescClick(pos(1, 1));
        
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(region).dimension);
        
        disp(['You clicked R:' num2str(region) ', row:' num2str(pos(1, 2)) ', col:', num2str(pos(1, 1))]);
        disp(['You clicked R:' num2str(region) ', row:' num2str(row) ', col:', num2str(col)]);
        
        if region > 2,
            updateWeightPlot(region, row, col);
        end
        
        % Do feature plot ========================
        
        v1Dimension = networkDimensions(1).dimension;

        axisVals(1, 3) = subplot(numRegions, 3, 3*(numRegions-1));

        hold off;
        
        features = findV1Sources(region, depth, row, col);
        numFeatures = length(features);
        
        if numFeatures > 0,
        
            for k = 1:numFeatures,
                drawFeature(features(k).row, features(k).col, features(k).depth);
            end
        else
             % this is needed in case there are no features found, because in this
             % case we would ordinarily not get the content cleared, even
             % with hold off.
            plot([(v1Dimension+1)/2 (v1Dimension+1)/2], [0 v1Dimension+1], 'r');
            hold on;
            plot([0 v1Dimension+1], [(v1Dimension+1)/2 (v1Dimension+1)/2], 'r');
        end
        
        % Since we use plot axis for feature plot,
        % which has reversed axis, we must reverse axis
        set(gca,'YDir','reverse');
        
        axis([0 v1Dimension+1 0 v1Dimension+1]);
        
        updateInvariancePlot(region, row, col);
        
        % sources = cell  of struct  (1..n_i).(col,row,depth, productWeight)  
        function [sources] = findV1Sources(region, depth, row, col)

            if region == 1, % termination condition, V1 cells return them self

                % Make 1x1 struct array
                sources(1).region = region;
                sources(1).row = row;
                sources(1).col = col;
                sources(1).depth = depth;

            elseif region > 1, 

                synapses = afferentSynapseList(connectivityFileID, neuronOffsets2, region, depth, row, col);

                sources = [];
                
                for s=1:length(synapses) % For each child

                    % Check that presynaptic neuron is in lower region (in
                    % case feedback network we dont want eternal loop), and
                    % that weight is over threshold
                    if synapses(s).weight > THRESHOLD && synapses(s).region < region
                        sources = [sources findV1Sources(synapses(s).region, synapses(s).depth, synapses(s).row, synapses(s).col)];
                    end
                end
            end
        end

    end

    function updateInvariancePlot(region, row, col)
        
        % Populate invariance plot
        subplot(numRegions, 3, [3*(numRegions-1) + 1, 3*(numRegions-1) + 3]);
        
        for obj=1:numObjects,
            
            plot(regionActivity{region - 1}(historyDimensions.numOutputsPrTransform, :, obj, numEpochs, row, col)); %> floatError
            hold all;
        end  
        
        axis([1 numTransforms -0.1 1.1]);
        
        hold;
    end

    function updateWeightPlot(region, row, col) 

        % Get weightbox
        weights = afferentSynapseMatrix(connectivityFileID, networkDimensions, neuronOffsets2, region, depth, row, col, region - 1, 1);

        % Save axis
        axisVals(region - 1, 3) = subplot(numRegions, 3, 3*(numRegions - region - 1 + 1) + 3);
        im2 = imagesc(weights);
        colorbar;
        %axis square;

        % Setup callback
        if region > 2,
            set(im2, 'ButtonDownFcn', {@connectivityCallBack, region - 1});
        end
    end
end

% Made with random experiemtnation with imagesc behavior, MAY not work
% in other settings because of border BS, check it out later, use
% ginput() if possible 
function [row, col] = imagescClick(i, j, dimension)

    if i < 1
        row = 1;
    else
        row = floor(i);
    end

    if j < 0.5
        col = 1;
    else
        col = round(j);

        if col > dimension,
            col = dimension;
        end
    end
end

function drawFeature(row, col, depth)

    halfSegmentLength = 3;%0.5;
    [orrientation, wavelength, phase] = decodeDepth(depth);
    featureOrrientation = orrientation + 90; % orrientation is the param to the filter, but it corresponds to a perpendicular image feature

    dx = halfSegmentLength * cos(featureOrrientation);
    dy = halfSegmentLength * sin(featureOrrientation);

    x1 = col - dx;
    x2 = col + dx;
    y1 = row - dy;
    y2 = row + dy;
    plot([x1 x2], [y1 y2], '-r');
    hold on;

end   

function [orrientation, wavelength, phase] = decodeDepth(depth)

    Phases = [0, 180];
    Orrientations = [0, 45, 90, 135];
    Wavelengths = [4];
    
    depth = uint8(depth)-1; % These formula expect C indexed depth, since I copied from project

    w = mod((idivide(depth, length(Phases))), length(Wavelengths));
    wavelength = Wavelengths(w+1);
    
    ph = mod(depth, length(Phases));
    phase = Phases(ph+1);
    
    o = idivide(depth, (length(Wavelengths) * length(Phases)));
    orrientation = Orrientations(o+1);
end 
