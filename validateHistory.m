
function validateHistory(file, historyDimensions, objects, transforms, epochs, ticks)

    if nargin > 2 && min(objects) > 0 && max(objects) <= historyDimensions.numObjects,
        disp([file ' error: object ' max(objects) ' does not exist'])
        exit;
    elseif nargin > 3 && min(transforms) > 0 && max(transforms) <= historyDimensions.numTransforms,
        disp([file ' error: transform ' max(transforms) ' does not exist'])
        exit;
    elseif nargin > 4 && min(epochs) > 0 && max(epochs) <= historyDimensions.numEpochs,
        disp([file ' error: epoch ' max(epochs) ' does not exist'])
        exit;
    elseif nargin > 5 && min(ticks) > 0 && max(ticks) <= historyDimensions.numOutputsPrTransform,
        disp([file ' error: tick ' max(ticks) ' does not exist'])
        exit;
    end