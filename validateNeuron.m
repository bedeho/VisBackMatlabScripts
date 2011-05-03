
function validateNeuron(file, networkDimensions, region, depth, row, col)

    if nargin > 2 && region > 0 && region < length(networkDimensions),
        disp([file ' error: region ' region ' does not exist'])
        exit;
    elseif nargin > 3 && depth > 0 && depth <= networkDimensions(region).depth,
        disp([file ' error: depth ' region ' does not exist'])
        exit;
    elseif nargin > 4 && row > 0 && row <= networkDimensions(region).dimension,
        disp([file ' error: row ' row ' does not exist'])
        exit;
    elseif nargin > 5 && col > 0 && col <= networkDimensions(region).dimension,
        disp([file ' error: col ' col ' does not exist'])
        exit;
    end