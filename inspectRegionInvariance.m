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
            regionHistogram = hist(q,1:(numTransforms+1)); % One extra for the 0 bucket
            plot(regionHistogram(2:(numTransforms+1)));
            hold all;
        end
        
        axis tight;
        
        % Save axis
        axisVals(r-1, 2) = subplot(numRegions, 3, 3*(r-2) + 2);
        
        % Plot region invarinceCount
        w = regionActivity{r - 1}(historyDimensions.numOutputsPrTransform, :, :, numEpochs, :, :);
        invarinceCount = squeeze(sum(sum(w > floatError))); %sum goes along first non singleton dimension, so it skeeps all our BS 1dimension
        im = imagesc(invarinceCount');
        colorbar
        colormap(jet(numTransforms + 1));
        
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
    for r=(numRegions-1):-1:1
        
        % Get region dimension
        regionDimension = networkDimensions(r).dimension;
        
        % Save axis
        axisVals(r, 3) = subplot(numRegions, 3, 3*(r-1) + 3);
        
        % Only setup callback for V2+
        if r > 1,
            im = imagesc(zeros(regionDimension));
            colorbar;

            set(im, 'ButtonDownFcn', {@connectivityCallBack, r});
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CALLBACKS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function invarianceCallBack(varargin)
        
        % Extract region,row,col
        region = varargin{3};
        pos=get(axisVals(region-1, 2), 'CurrentPoint');
        
        row = imagescClick(pos(1, 2));
        col = imagescClick(pos(1, 1));
        
        disp(['You clicked X:' num2str(col) ', Y:', num2str(row)]);
        
        updateInvariancePlot(region, row, col);
        
        % For top region, initiate weight plot
        if region == numRegions,
            updateWeightPlot(numRegions, row, col);
        end
    end
    
    function connectivityCallBack(varargin)
        
        % Extract region,row,col
        region = varargin{3};
        
        pos=get(axisVals(region, 3), 'CurrentPoint');
        
        row = imagescClick(pos(1, 2));
        col = imagescClick(pos(1, 1));
        
        disp(['You clicked X:' num2str(col) ', Y:', num2str(row)]);
        
        if region > 2
            updateWeightPlot(region, row, col);
        else
            
            % Open file
            connectivityFileID = fopen([folder '/' networkFile]);

            % Read header
            [networkDimensions, neuronOffsets2] = loadWeightFileHeader(connectivityFileID);
    
            % Do feature plot
            v1Dimension = networkDimensions(1).dimension
            

            axisVals(1, 3) = subplot(numRegions, 3, 3);
            
            hold off
            
            synapses = afferentSynapseList(connectivityFileID, neuronOffsets2, region, depth, row, col);
            
            for s = 1:length(synapses),
                drawFeature(synapses(s).row, synapses(s).col, synapses(s).depth, synapses(s).weight)
            end
            
            axis([0 v1Dimension+1 0 v1Dimension+1]); 
            
            fclose(connectivityFileID);
        end
        
        updateInvariancePlot(region, row, col);
    end

    function [res] = imagescClick(i)

        if i < 0.5
            res = 1;
        else
            res = round(i);
        end
    end

    function updateInvariancePlot(region, row, col)
        
        % Populate invariance plot
        subplot(numRegions, 3, [3*(numRegions-1) + 1, 3*(numRegions-1) + 3]);
        
        for obj=1:numObjects,
            
            w2 = regionActivity{region - 1}(historyDimensions.numOutputsPrTransform, :, obj, numEpochs, row, col);
            q2 = w2 > floatError;
            plot(q2);
            hold all;
        end  
        
        axis([1 numTransforms -0.1 1.1]);
        
        hold;
    end

    function updateWeightPlot(region, row, col) 
        
        % Open file
        connectivityFileID = fopen([folder '/' networkFile]);

        % Read header
        [networkDimensions, neuronOffsets2] = loadWeightFileHeader(connectivityFileID);

        % Get weightbox
        weights = afferentSynapseMatrix(connectivityFileID, networkDimensions, neuronOffsets2, region, depth, col, row, region - 1, 1);

        % Save axis
        r2 = region - 1;
        axisVals(r2, 3) = subplot(numRegions, 3, 3*(r2-1) + 3);
        im2 = imagesc(weights);
        colorbar;

        % Setup callback
        set(im2, 'ButtonDownFcn', {@connectivityCallBack, r2});
        
        fclose(connectivityFileID); 
    end

end

function drawFeature(row, col, depth, weight)

    if weight > 0.2, %average weight in untrained net I think, calculate later
        halfSegmentLength = 0.5;
        [orrientation, wavelength, phase] = decodeDepth(depth);
        featureOrrientation = orrientation + 90; % orrientation is the param to the filter, but it corresponds to a perpendicular image feature

        dx = halfSegmentLength * cos(featureOrrientation);
        dy = halfSegmentLength * sin(featureOrrientation);

        x1 = col - dx;
        x2 = col + dx;
        y1 = row - dy;
        y2 = row + dy;
        plot([x1 x2], [y1 y2], '-');
        hold on;
    end
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


% sources = cell  of struct  (1..n_i).(col,row,depth, productWeight)  
function [sources] = findV1Sources(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch)

    THRESHOLD = 0.2;

    if region == 1, % termination condition, V1 cells return them self

        % Make 1x1 struct array
        sources(1).region = region;
        sources(1).row = row;
        sources(1).col = col;
        sources(1).depth = depth;
        sources(1).compound = 1;

    elseif region > 1, 

        synapses = synapseHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch);
        afferentSynapseCount = length(synapses);

        childSources = cell(afferentSynapseCount, 1);

        % Notice that we add +1 since the numbers from the file is in
        % 0 based C++ indexing
        for s=1:afferentSynapseCount % For each child
            childSources{s} = findV1Sources(fileID, networkDimensions, historyDimensions, neuronOffsets, synapses(s).region + 1, synapses(s).depth + 1, synapses(s).row + 1, synapses(s).col + 1, maxEpoch);
        end
        
        % For each synapse, look up pool of features
        % it is connected to for present time, and
        % include in .this neurons pool for this time
        % given certain critirea, e.g. if synapse is
        % strong enough, or compund weight is strong
        % enough etc.

        % Count the number of neurons we will have
        childSourcesSize = 0;
        for s=1:afferentSynapseCount, 

            if synapses(s).activity(ti, t, o, e) > THRESHOLD,
                childSourcesSize = childSourcesSize + length(childSources{s}{ti, t, o, e});
            end
        end

        % Make childSourcesSizex1 struct array
        if childSourcesSize > 0,
            v(childSourcesSize).region = region;
            v(childSourcesSize).row = row;
            v(childSourcesSize).col = col;
            v(childSourcesSize).depth = depth;
            v(childSourcesSize).compound = 1;

            sources{ti, t, o, e} = v;

            counter = 1;
            for s=1:afferentSynapseCount, 

                % If this synapse is stronger then
                % threshold at this time, then we
                % included properly, otherwise we put 0 in
                % its place
                if synapses(s).activity(ti, t, o, e) > THRESHOLD,

                     for cs=1:length(childSources{s}{ti, t, o, e}),
                         sources(counter).region = childSources{s}(cs).region;
                         sources(counter).row = childSources{s}(cs).row;
                         sources(counter).col = childSources{s}(cs).col;
                         sources(counter).depth = childSources{s}(cs).depth;
                         sources(counter).compound = childSources{s}(cs).compound * synapses(s).activity(ti, t, o, e);
                         counter = counter + 1;    
                     end
                end
            end
        else
            sources = [];
        end
    end