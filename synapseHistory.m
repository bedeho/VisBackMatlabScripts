%
%  afferentSynapseList.m
%  VisBack
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  AFFERENT SYNAPSES FOR ONE NEURON
%  Input=========
%  fileID: fileID of open weight file
%  region: neuron region
%  col: neuron column
%  row: neuron row
%  depth: neuron depth
%  sourceRegion: afferent region id (V1 = 1)
%  sourceDepth: depth to plot in source region (first layer = 1)
%  Output========
%  synapses: Returns struct array of all synapses (regionNR,depth,row,col,weight) into neuron




%
%  neuronHistory.m
%  VisBack
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Input=========
%  fileID: fileID of open weight file
%  networkDimensions: 
%  historyDimensions: 
%  neuronOffsets: cell array giving byte offsets (rel. to 'bof') of neurons 
%  region: neuron region
%  col: neuron column
%  row: neuron row
%  depth: neuron depth
%  maxEpoch (optional): largest epoch you are interested in
%  Output========
%  Activity history of region: 4-d matrix (timestep, transform, object, epoch)

function [activity] = neuronHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch)

    % Import global variables
    global SOURCE_PLATFORM_USHORT;
    global SYNAPSE_ELEMENT_SIZE;
    global SOURCE_PLATFORM_FLOAT;
   
    % Find offset of synapse list of neuron region.(depth,i,j)
    offsetCount = list{region}{col,row,depth}.offsetCount;
    fseek(fileID, headerSize + offsetCount * SYNAPSE_ELEMENT_SIZE, 'bof');
    
    % Allocate synapse struct array
    afferentSynapseCount = list{region}{col,row,depth}.afferentSynapseCount;
    synapses(afferentSynapseCount).regionNr = [];
    synapses(afferentSynapseCount).depth = [];
    synapses(afferentSynapseCount).row = [];
    synapses(afferentSynapseCount).col = [];
    synapses(afferentSynapseCount).weight = [];
    
    % Fill synapses
    for s = 1:afferentSynapseCount,
        v = fread(fileID, 4, SOURCE_PLATFORM_USHORT);
        
        synapses(s).regionNr = v(1);
        synapses(s).depth = v(2);
        synapses(s).row = v(3);
        synapses(s).col = v(4);
        synapses(s).weight = fread(fileID, 1, SOURCE_PLATFORM_FLOAT);
    end
