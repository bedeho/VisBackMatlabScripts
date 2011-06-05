%
%  plotRegionInvariance.m
%  VisBack
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  PLOT REGION INVARIANCE FOR ALL SIMULATION FILES IN ALL SIMULATIONS
%  Input=========
%  project: project name
%  experiment: experiment name
%  simulation: simulation name

function plotExperimentInvariance(project, experiment)

    PROJECTS_FOLDER = '/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/';  % must have trailing slash

    experimentFolder = [PROJECTS_FOLDER project '/Simulations/' experiment '/'];
    
    % Iterate simulations in this experiment folder
    listing = dir(experimentFolder); 
    
    % Save results for summary
    filename = [experimentFolder 'Summary.html'];
    fileID = fopen(filename, 'w'); % did note use datestr(now) since it has string
    
    fprintf(fileID, '<h1>%s - %s</h1>\n', experiment, datestr(now));
    fprintf(fileID, '<table cellpadding="10" style="border: solid 1px">\n');
    fprintf(fileID, '<tr> <th>Simulation</th> <th>Network</th> <th>#Invariant</th> <th>Mean(Invariance level)</th> <th>SCA</th> <th>MCA</th> <th>Figure</th> <th>Inspector</th> <th>Firing</th> <th>Activation</th> <th>InhibitedActivation</th> <th>Trace</th> </tr>\n');
    
    %h = waitbar(0, 'Plotting&Infoanalysis...');
    counter = 1;
    
    for d = 1:length(listing),

        % We are only looking for directories, but not the
        % 'Filtered' directory, since it has filtered output
        simulation = listing(d).name;

        if listing(d).isdir && ~any(strcmp(simulation, {'Filtered', 'Images', '.', '..'})),
            
            % Waitbar messes up -nodisplay option
            %waitbar(counter/(nnz([listing(:).isdir]) - 2), h);
            disp(['******** Doing ' num2str(counter) ' out of ' num2str((nnz([listing(:).isdir]) - 2)) '********']); 
            counter = counter + 1;
            
            summary = plotSimulationRegionInvariance(project, experiment, simulation);

            for s=1:length(summary),
                
                netDir = [experimentFolder  simulation '/' summary(s).directory];
                
                figCommand                  = ['matlab:open(\''' netDir '/invariance.fig\'')'];
                inspectorCommand            = ['matlab:inspectRegionInvariance(\''' netDir '\'',\''' summary(s).directory '.txt\'')'];
                firingCommand               = ['matlab:plotNetworkHistory(\''' netDir '/firingRate.dat\'')'];
                activationCommand           = ['matlab:plotNetworkHistory(\''' netDir '/activation.dat\'')'];
                inhibitedActivationCommand  = ['matlab:plotNetworkHistory(\''' netDir '/inhibitedActivation.dat\'')'];
                traceCommand                = ['matlab:plotNetworkHistory(\''' netDir '/trace.dat\'')'];
                
                fprintf(fileID, '<tr>\n'); %flip color here
                fprintf(fileID, '<td> %s </td>\n', simulation);
                fprintf(fileID, '<td> %s </td>\n', summary(s).directory);
                fprintf(fileID, '<td> %d </td>\n', summary(s).fullInvariance);
                fprintf(fileID, '<td> %d </td>\n', summary(s).meanInvariance);
                
                if summary(s).nrOfSingleCell < 0.1,
                    fprintf(fileID, '<td style=''background-color:green;''> %d </td>\n', summary(s).nrOfSingleCell);
                else    
                    fprintf(fileID, '<td> %d </td>\n', summary(s).nrOfSingleCell);
                end
                
                if summary(s).multiCell < 0.1,
                    fprintf(fileID, '<td style=''background-color:green;''> %d </td>\n', summary(s).multiCell);
                else
                    fprintf(fileID, '<td> %d </td>\n', summary(s).multiCell);
                end
                
                fprintf(fileID, '<td> <input type="button" value="Figure" onclick="document.location=''%s''"/></td>\n', figCommand);
                fprintf(fileID, '<td> <input type="button" value="Inspector" onclick="document.location=''%s''"/></td>\n', inspectorCommand);
                fprintf(fileID, '<td> <input type="button" value="Firing" onclick="document.location=''%s''"/></td>\n', firingCommand);
                fprintf(fileID, '<td> <input type="button" value="Activation" onclick="document.location=''%s''"/></td>\n', activationCommand);
                fprintf(fileID, '<td> <input type="button" value="InhibitedActivation" onclick="document.location=''%s''"/></td>\n', inhibitedActivationCommand);
                fprintf(fileID, '<td> <input type="button" value="Trace" onclick="document.location=''%s''"/></td>\n', traceCommand);
                fprintf(fileID, '</tr>\n');
            end
            
        end
    end
    
    %close(h);
    
    fprintf(fileID, '</table>');
    fclose(fileID);
    
    %web(filename);
    
    disp([experiment ' 100% DONE.']);
    
    