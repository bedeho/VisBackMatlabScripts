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
    sources = findV1Sources(region, depth, row, col);
    
    figure();
    for s=1:length(synapses),

        % Plot
        v = synapses(s).activity(:, :, :, 1:maxEpoch);
        plot(reshape(v, [1 streamSize]));
        hold on;
    end
    
    fclose(fileID);
    
    % sources = struct array (timestep, transform, object, epoch).(col,row,depth, productWeight)
    
    function [sources] = findV1Sources(networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch)
        
        if region == 1, % termination condition, V1 cells return them self
            sources = zeros(historyDimensions.numOutputsPrTransform, historyDimensions.numTransforms, historyDimensions.numObjects, maxEpoch);
        elseif region > 1, 
        
            synapses = synapseHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch);
            % (timestep, transform, object, epoch)
            
            for s=1:length(synapses), % For each synapse
                childSources(s) = findV1Sources(networkDimensions, historyDimensions, neuronOffsets, synapses(s).regionNr, synapses(s).depth, synapses(s).row, synapses(s).col, maxEpoch);
            end 
            
            % Iterate history,
            for e=1:maxEpoch,
                for o=1:historyDimensions.numObjects,
                    for t=1:historyDimensions.numTransforms,
                        for ti=1:historyDimensions.numOutputsPrTransform,
                            
                            for s=1:length(synapses), % For each synapse
                                
                            end

                            %if synapses(s).activity(ti, t, o, e)

                            %sources = [sources ];
                        end
                    end
                end
            end
            
        end
    
    function initCanvas()
    
    function drawFeature(depth, row, col, weight)
        
    function [orrientation, wavelength, phase] = decodeDepth(depth)
        
    