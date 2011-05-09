%
%  plotFeatureHistory.m
%  VisBack
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Input=========
%  filename: filename of weight file
%  region: region to plot, V1 = 1
%  depth: region depth to plot
%  row: neuron row
%  col: neuron column
%  maxEpoch: last epoch to plot
%  Output========
%  Plots line plot of activity for spesific neuron

function plotFeatureHistory(folder, region, depth, row, col, maxEpoch)

    % Import global variables
    declareGlobalVars();
    
    synapseFile = [folder '/synapticWeights.dat'];
    
    % Open file
    fileID = fopen(synapseFile);
    
    % Read header
    [networkDimensions, historyDimensions, neuronOffsets] = loadSynapseWeightHistoryHeader(fileID);
    
    if nargin < 6,
        maxEpoch = historyDimensions.numEpochs; % pick all epochs
    end
    
    streamSize = maxEpoch * historyDimensions.epochSize;
    
    % Get history array
    sources = findV1Sources(networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch)
    
    %{
    figure();
    for s=1:length(synapses),

        % Plot
        v = synapses(s).activity(:, :, :, 1:maxEpoch);
        plot(reshape(v, [1 streamSize]));
        hold on;
    end
    
    fclose(fileID);
    %}
    
% sources = cell array {timestep, transform, object, epoch}.(col,row,depth, productWeight)  
function [sources] = findV1Sources(networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch)

        THRESHOLD = 0.2;

        % Allocate space for history
        sources = cell(historyDimensions.numOutputsPrTransform, historyDimensions.numTransforms, historyDimensions.numObjects, maxEpoch);
            
        if region == 1, % termination condition, V1 cells return them self
            
            % Iterate history,
            for e=1:maxEpoch,
                for o=1:historyDimensions.numObjects,
                    for t=1:historyDimensions.numTransforms,
                        for ti=1:historyDimensions.numOutputsPrTransform,
                            
                            % Make 1x1 struct array
                            v(1).region = region;
                            v(2).row = row;
                            v(3).col = col;
                            v(4).compound = 1;
                            
                            sources{ti, t, o, e} = v;
                        end
                    end
                end
            end
      elseif region > 1, 
        
            synapses = synapseHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch);
            afferentSynapseCount = length(synapses);
            
            childSources = cell(afferentSynapseCount, 1);
            
            for s=1:afferentSynapseCount % For each child
                childSources(s) = findV1Sources(networkDimensions, historyDimensions, neuronOffsets, synapses(s).region, synapses(s).depth, synapses(s).row, synapses(s).col, maxEpoch);
            end
            
            % Iterate history,
            for e=1:maxEpoch,
                for o=1:historyDimensions.numObjects,
                    for t=1:historyDimensions.numTransforms,
                        for ti=1:historyDimensions.numOutputsPrTransform,
                            
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
                            v(childSourcesSize).region = region;
                            v(childSourcesSize).row = row;
                            v(childSourcesSize).col = col;
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
                                         sources{ti, t, o, e}(counter).region = childSources{s}{ti, t, o, e}(cs).region;
                                         sources{ti, t, o, e}(counter).col = childSources{s}{ti, t, o, e}(cs).col;
                                         sources{ti, t, o, e}(counter).row = childSources{s}{ti, t, o, e}(cs).row;
                                         sources{ti, t, o, e}(counter).compound = childSources{s}{ti, t, o, e}(cs).compound * synapses(s).activity(ti, t, o, e);
                                         counter = counter + 1;    
                                     end
                                end
                            end
                        end
                    end
                end
            end
        end
    
function initCanvas()
    
function drawFeature(depth, row, col, weight)
        
function [orrientation, wavelength, phase] = decodeDepth(depth)
        
    