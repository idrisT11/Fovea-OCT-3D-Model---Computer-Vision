
clear all;
close all;

% slicesILM = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\ILM\slicesILM_08_TRK_OD.mat').slicesILM;
% slicesHRC = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\HRC\slicesHRC_08_TRK_OD.mat').slicesHRC;

% slicesILM = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\ILM\slicesILM_04_BIM_OD.mat').slicesILM;
% slicesHRC = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\HRC\slicesHRC_04_BIM_OD.mat').slicesHRC;

slicesILM = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\ILM\slicesILM_02-DEA_OD.mat').slicesILM;
slicesHRC = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\HRC\slicesHRC_02-DEA_OD.mat').slicesHRC;

% slicesILM = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\ILM\slicesILM_01-CABONS OD.mat').slicesILM;
% slicesHRC = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\HRC\slicesHRC_01-CABONS OD.mat').slicesHRC;



for i=1:48
    flattenFoveaILM(slicesILM{i}, slicesHRC{i}, false);
end


function [T, T2] = alignementHRCParameters(sliceHRC)

    leftMost = sliceHRC(:, 1);
    rightMost = sliceHRC(:, end);
    angle = atan((rightMost(1)-leftMost(1)) / (rightMost(2)-leftMost(2)));

    T = [
        cos(angle) -sin(angle)   -leftMost(2); ...
        sin(angle)  cos(angle)   -leftMost(1); ...
        0           0            1; ...
    ];

    T2 = [
        1 0    leftMost(2); ...
        0 1    leftMost(1); ...
        0           0            1; ...
    ];

end

function [R_slice] = applyTransformation(T, slice)

    pointsHomogeneous = [slice; ones(1, size(slice, 2))];
    transformedPointsHomogeneous = T * pointsHomogeneous;
    R_slice = transformedPointsHomogeneous(1:2, :);
end

function [leftEdge, foveaPit, rightEdge] = computeAnchorPoints(flattenedILM, originalILM, flattenedDerivative, decalageVector)

    nbPoints = size(originalILM, 2);

    % Compute the fovea pit's position
    %--------------------------------------------------------------
    centralThird = ceil(nbPoints/3):ceil(2*nbPoints/3);
    foveaPitY  = max(flattenedILM(1, centralThird));
    foveaPitX  = originalILM(2, find(flattenedILM == foveaPitY));

    % Compute the left and right local maxima (left and right saddle points
    % of the depression)
    %--------------------------------------------------------------
    leftSaddlePoint  = max(flattenedDerivative(1, centralThird));
    leftSaddlePointX  = originalILM(2, find(flattenedDerivative == leftSaddlePoint));
    leftSaddlePointY  = flattenedILM(1, find(flattenedDerivative == leftSaddlePoint));

    rightSaddlePoint  = min(flattenedDerivative(1, centralThird));
    rightSaddlePointX  = originalILM(2, find(flattenedDerivative == rightSaddlePoint));
    rightSaddlePointY  = flattenedILM(1, find(flattenedDerivative == rightSaddlePoint));


    % Looks for the left and right edges of the fovea depression
    %--------------------------------------------------------------
    window = 20;
    k = find(flattenedDerivative == leftSaddlePoint);
    while (mean(flattenedDerivative(k-window:k)) > 0) && (k - window > 0)
        k = k - 1;
    end

    m = find(flattenedDerivative == rightSaddlePoint);
    while (mean(flattenedDerivative(m:m+window)) < 0) && (m + window < length(flattenedDerivative))
        m = m + 1;
    end

    % Output
    %--------------------------------------------------------------
    leftEdge =  [flattenedILM(k)+decalageVector(k)     originalILM(2, k)];
    rightEdge = [flattenedILM(m)+decalageVector(m)     originalILM(2, m)];
    foveaPit =  [foveaPitY+decalageVector(find(flattenedILM == foveaPitY))           foveaPitX];
end

% =======================================================
% le paramtre doDisplay sert à desactiver le printing
% =======================================================
function [foveaPit, leftEdge, rightEdge, flattenedILM] = flattenFoveaILM(sliceILM, sliceHRC, doDisplay)
    
    % Smoothing our curves with the gaussian method
    % ---------------------------------------------------------
    sliceILM(1,:) = smoothdata(sliceILM(1,:), 'gaussian', 4);
    sliceHRC(1,:) = smoothdata(sliceHRC(1,:), 'gaussian', 4);

    % Remove any quircks from the data (doublants)
    % ---------------------------------------------------------
    sliceHRC = unique(sliceHRC', 'rows', 'stable')';
    sliceHRC = sliceHRC(:, 1:end-1);


    % Realign ILM to HRC slices
    % ---------------------------------------------------------
    [T, T2] = alignementHRCParameters(sliceHRC);

    R_sliceHRC = applyTransformation(T, sliceHRC);
    R_sliceHRC = applyTransformation(T2, R_sliceHRC);

    
    R_sliceILM = applyTransformation(T, sliceILM);
    R_sliceILM = applyTransformation(T2, R_sliceILM);

    sliceHRC = R_sliceHRC;
    sliceILM = R_sliceILM;


    % Crop extra length
    % ---------------------------------------------------------
    minX = max(min(sliceILM(2, :)), min(sliceHRC(2, :)));
    maxX = min(max(sliceILM(2, :)), max(sliceHRC(2, :)));

    sliceILM = sliceILM(:, sliceILM(2, :) >= minX & sliceILM(2, :) <= maxX);
    sliceHRC = sliceHRC(:, sliceHRC(2, :) >= minX & sliceHRC(2, :) <= maxX);

    nbPoints = size(sliceILM, 2);
    
    % Plot the HRC curve
    % ++++++++++++++++++++
    if(doDisplay)
        figure(65);
        plot(sliceHRC(2,:), sliceHRC(1,:));
        hold on;
    end

    % Interpolate the HRC curve so that it has the same number of points as
    % the ILM curve
    % ---------------------------------------------------------
    iSliceHRC = zeros(2, nbPoints);
    iSliceHRC(1, :) = interp1(sliceHRC(2,:), sliceHRC(1,:), sliceILM(2, :));
    iSliceHRC(2, :) = sliceILM(2, :);

    
    % Compute the flattenILM curve and its derivative
    % ---------------------------------------------------------
    flattenedILM = sliceILM(1,:) - iSliceHRC(1,:);
    smoothedflattenedILM = smoothdata(flattenedILM, 'gaussian', 40);
    flattenedDerivative = diff(smoothedflattenedILM) ./ diff(sliceILM(2,:));
    
    [leftEdge, foveaPit, rightEdge] = computeAnchorPoints(flattenedILM, sliceILM, flattenedDerivative, iSliceHRC(1,:));
    

    if(doDisplay)
        % Plot the flattened ILM curve and its derivative
        % +++++++++++++++++++++++++++++++++++++++++++
        figure(2);
        subplot(2, 1, 1);
        plot(sliceILM(2,:), -smoothedflattenedILM);
        hold on;
        subplot(2, 1, 2);
        plot(sliceILM(2,1:end-1), flattenedDerivative);
        hold on;
    
        % Plot the original ILM curve with its anchor points
        % +++++++++++++++++++++++++++++++++++++++++++  
        figure(3);
        plot(sliceILM(2,:), sliceILM(1,:));
        hold on;
        plot(foveaPit(2), foveaPit(1), 'Marker','+','Color','r');
        hold on;
        plot(leftEdge(2), leftEdge(1), 'Marker','+','Color','g');
        hold on;
        plot(rightEdge(2), rightEdge(1), 'Marker','+','Color','g');
    end

end


% Old code for ploting the saddle points
% --------------------------------------------
%     figure(2);
%     plot(sliceILM(2,:), -flattenedILM);
%     hold on;
%     plot(foveaPitX, -foveaPitY, 'Marker','+','Color','r');
%     hold on;
%     plot(leftSaddlePointX, -leftSaddlePointY, 'Marker','+','Color','g');
%     hold on;
%     plot(rightSaddlePointX, -rightSaddlePointY, 'Marker','+','Color','g');



