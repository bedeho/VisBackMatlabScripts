function [] = filterImageSet(inputDirectory, imageSize)

%inputDirectory = Directory where we look for /Images folder with
%input pictures, and where we save /Filtered folder with output and
%files FileList.txt and FilteredParameters.txt
% NO TRAILINGNSLASH
%
%imageSize = is the size you expect images to be, this is tested
%against real image size prior to filtering as safety, been burned
%to many times!!!

if nargin < 2,
    error('Arguments not supplied');
end

tic;
imageParamFile = 'FilterParameters.txt';
imageListFile = 'FileList.txt';
paddingGrayScaleColor = 127;
outdir = [inputDirectory '/Filtered'];
set = true;
ext='.png';

% READ: http://www.cs.rug.nl/~imaging/simplecell.html 
psi   = [0, pi, -pi/2, pi/2];                        % phase, [0, pi, -pi/2, pi/2]
scale = [2];                        % wavelength (pixels)
orient= [0, pi/4, pi/2, 3*pi/4];    % orientation
bw    = 1.8;                        % bandwidth
gamma = 0.5;                        % aspect ratio

% Create parameters file ===========================================

vPhases = ['[' num2str(rad2deg(psi(1)))];
for p = 2:length(psi)
    vPhases = [vPhases ', ' num2str(rad2deg(psi(p)))];
end
vPhases = [vPhases ']'];

vScales = ['[' num2str(scale(1))];
for s = 2:length(scale)
    vScales = [vScales ', ' num2str(scale(s))];
end
vScales = [vScales ']'];

vOrients = ['[' num2str(orient(1))];
for o = 2:length(orient)
    vOrients = [vOrients ', ' num2str(rad2deg(orient(o)))];
end
vOrients = [vOrients ']'];

iParams = fopen([inputDirectory,'/',imageParamFile],'w+');
fprintf(iParams, ['vPhases = ' vPhases ' ;\n'] );
fprintf(iParams, ['vScales = ' vScales ' ;\n'] );
fprintf(iParams, ['vOrients = ' vOrients ' ;\n'] );

code = fclose(iParams);

if code ~= 0
    error('Problem closing iParams');
end

% Save results for summary ===========================================

fileID = fopen([inputDirectory filesep 'Summary.html'], 'w'); 
fprintf(fileID, '<h1>Filtering - %s</h1>\n', date());

fprintf(fileID,  '<ul>\n');
fprintf(fileID, ['<ul> Phases - ' vPhases '</ul>\n']);
fprintf(fileID, ['<ul> Scales - ' vScales '</ul>\n']);
fprintf(fileID, ['<ul> Orients - ' vOrients '</ul>\n']);
fprintf(fileID,  '</ul>\n');

fprintf(fileID, '<table cellpadding="10" style="border: solid 1px">\n');
fprintf(fileID, '<tr> <th>Image</th> <th>Filter</th> <th>Image</th> </tr>\n');

% Filter & create file list and summary ========================================

iList = fopen([inputDirectory,'/',imageListFile],'w+');

content = dir([inputDirectory,'/Images']);
cell = struct2cell(content);
[~,ind] = sort_nat(cell(1,:)); % Sort numerically according to first row (name)
clear cell;% S;

for i = 1:length(content)
    file = content(ind(i)).name;
    if ~(content(ind(i)).isdir)
        ignoreDir = any(strcmpi(file, {'private','CVS','.','..'}));
        [~,fname,fext] = fileparts(file); % fver returned
        ignorePrefix = any(strncmp(file, {'@','.'}, 1));
        if (~(ignoreDir || ignorePrefix) && strcmpi(ext,fext))
            
            % Open file
            imgFile = [inputDirectory '/Images/' file];
            finfo = imfinfo(imgFile);
            
            % Test for expected image size
            if finfo.Height ~= imageSize || finfo.Width ~= imageSize,
                disp(['UNEXPECTED IMAGE SIZE FOUND: ' finfo.Height ',' finfo.Width]);
                exit;
            end
            
            % Filter
            filtering(imgFile, psi, scale, orient, bw, gamma, set, paddingGrayScaleColor);
            
            % Dump to summary            
            [pathstr, name, ext] = fileparts([inputDirectory '/Filtered/' file]);
            viewFilters = ['matlab:plotFilters(\''' pathstr filesep name '\'',' num2str(imageSize) ',' vOrients ',' vPhases ',' vScales ')'];
            viewImage = ['matlab:figure;imshow(\''' inputDirectory '/Images/' file '\'')'];
            
            fprintf(fileID, '<tr>\n');
            fprintf(fileID, '<td>%s</td>\n', file);
            fprintf(fileID, '<td><input type="button" value="View" onclick="document.location=''%s''"/></td>\n', viewFilters);
            fprintf(fileID, '<td><input type="button" value="View" onclick="document.location=''%s''"/></td>\n', viewImage);
            fprintf(fileID, '</tr>\n');
            
            % Dump to file list
            fprintf(iList, '%s\n', fname); %was imagedir
        end
    end
end

code = fclose(iList);
if code ~= 0; error('Problem closing file list'); end

fprintf(fileID, '</table>');

fclose(fileID);

% Cleanup ========================================

toc;

% Delete existing output folder, make new
if exist(outdir, 'dir'),
    rmdir(outdir, 's');
end

mkdir(outdir);
    
cmd = ['mv ' inputDirectory '/Images/*.flt ' outdir];
[status, results] = system(cmd); % 2nd return value is the output of the cmd (results)
if (status ~= 0)
    disp(cmd);
    disp(results); 
    error('Problem moving filtered folders to /Filtered directory'); 
end


web([inputDirectory filesep 'Summary.html']);
