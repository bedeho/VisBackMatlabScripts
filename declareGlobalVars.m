
function declareGlobalVars() 

    % Data type sizes for platform that generated the output files
    global SOURCE_PLATFORM_UINT = 'uint32';
    global SOURCE_PLATFORM_UINT_SIZE = 4;
    global SOURCE_PLATFORM_USHORT = 'uint16';
    global SOURCE_PLATFORM_USHORT_SIZE = 2;
    global SOURCE_PLATFORM_FLOAT = 'float';
    global SOURCE_PLATFORM_FLOAT_SIZE = 4;
    global SYNAPSE_ELEMENT_SIZE = (4 * SOURCE_PLATFORM_USHORT_SIZE + SOURCE_PLATFORM_FLOAT_SIZE); % regionNr >> depth >> row >> col >> weight