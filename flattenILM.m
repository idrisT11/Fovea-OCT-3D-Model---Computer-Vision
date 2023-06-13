
clear all;
close all;

% slicesILM = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\ILM\slicesILM_08_TRK_OD.mat').slicesILM;
% slicesHRC = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\HRC\slicesHRC_08_TRK_OD.mat').slicesHRC;

slicesILM = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\ILM\slicesILM_04_BIM_OD.mat').slicesILM;
slicesHRC = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\HRC\slicesHRC_04_BIM_OD.mat').slicesHRC;

% slicesILM = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\ILM\slicesILM_02-DEA_OD.mat').slicesILM;
% slicesHRC = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\HRC\slicesHRC_02-DEA_OD.mat').slicesHRC;

% slicesILM = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\ILM\slicesILM_01-CABONS OD.mat').slicesILM;
% slicesHRC = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\HRC\slicesHRC_01-CABONS OD.mat').slicesHRC;



for i=1:48
    flattenFoveaILM(slicesILM{i}, slicesHRC{i},i);
end

function [foveaPit, leftEdge, rightEdge, flattenedILM] = flattenFoveaILM(sliceILM, sliceHRC, i)
    
    sliceILM(1,:) = smoothdata(sliceILM(1,:), 'gaussian', 4);
    sliceHRC(1,:) = smoothdata(sliceHRC(1,:), 'gaussian', 4);

    % Pour enlever lesdoublants
    sliceHRC = unique(sliceHRC', 'rows', 'stable')';
    sliceHRC = sliceHRC(:, 1:end-1);

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

    pointsHomogeneous = [sliceHRC; ones(1, size(sliceHRC, 2))];
    transformedPointsHomogeneous = T * pointsHomogeneous;
    R_sliceHRC = transformedPointsHomogeneous(1:2, :);

    pointsHomogeneous = [R_sliceHRC; ones(1, size(sliceHRC, 2))];
    transformedPointsHomogeneous = T2 * pointsHomogeneous;
    R_sliceHRC = transformedPointsHomogeneous(1:2, :);
    
     figure(5);
     plot(sliceHRC(2,:), sliceHRC(1,:));
     hold on;
     plot(R_sliceHRC(2,:), R_sliceHRC(1,:));
    
    % --------------
    pointsHomogeneous = [sliceILM; ones(1, size(sliceILM, 2))];
    transformedPointsHomogeneous = T * pointsHomogeneous;
    R_sliceILM = transformedPointsHomogeneous(1:2, :);

    pointsHomogeneous = [R_sliceILM; ones(1, size(sliceILM, 2))];
    transformedPointsHomogeneous = T2 * pointsHomogeneous;
    R_sliceILM = transformedPointsHomogeneous(1:2, :);


    sliceHRC = R_sliceHRC;
    sliceILM = R_sliceILM;

    % --- old code

    minX = max(min(sliceILM(2, :)), min(sliceHRC(2, :)));
    maxX = min(max(sliceILM(2, :)), max(sliceHRC(2, :)));

    vminX = max(min(sliceILM(2, :)), min(sliceHRC(2, :)));
    vmaxX = min(max(sliceILM(2, :)), max(sliceHRC(2, :)));
    
    figure(65);
    plot(sliceHRC(2,:), sliceHRC(1,:), 'DisplayName', "kk");


    sliceILM = sliceILM(:, sliceILM(2, :) >= minX & sliceILM(2, :) <= maxX);
    sliceHRC = sliceHRC(:, sliceHRC(2, :) >= minX & sliceHRC(2, :) <= maxX);

    nbPoints = size(sliceILM, 2);

    iSliceHRC = zeros(2, nbPoints);
    iSliceHRC(1, :) = interp1(sliceHRC(2,:), sliceHRC(1,:), sliceILM(2, :));
    iSliceHRC(2, :) = sliceILM(2, :);

    
%     if (i==1 || i==47|| true)
% 
%     figure(68);
%     plot(sliceILM(2,:), sliceILM(1,:), 'DisplayName', "kk");
%     hold on;
%     plot(iSliceHRC(2,:), iSliceHRC(1,:), 'DisplayName', "kk");
%     end


    
    flattenedILM = sliceILM(1,:) - iSliceHRC(1,:);

    flattenedILMe = smoothdata(flattenedILM, 'gaussian', 40);


    drv = diff(flattenedILMe) ./ diff(sliceILM(2,:));

    centralThird = ceil(nbPoints/3):ceil(2*nbPoints/3);
    foveaPitY  = max(flattenedILM(1, centralThird));
    foveaPitX  = sliceILM(2, find(flattenedILM == foveaPitY));

    leftSaddlePoint  = max(drv(1, centralThird));
    leftSaddlePointX  = sliceILM(2, find(drv == leftSaddlePoint));
    leftSaddlePointY  = flattenedILM(1, find(drv == leftSaddlePoint));

    rightSaddlePoint  = min(drv(1, centralThird));
    rightSaddlePointX  = sliceILM(2, find(drv == rightSaddlePoint));
    rightSaddlePointY  = flattenedILM(1, find(drv == rightSaddlePoint));
    
    figure(2);
    plot(sliceILM(2,:), -flattenedILM);
    hold on;
    plot(foveaPitX, -foveaPitY, 'Marker','+','Color','r');
%     hold on;
%     plot(leftSaddlePointX, -leftSaddlePointY, 'Marker','+','Color','g');
%     hold on;
%     plot(rightSaddlePointX, -rightSaddlePointY, 'Marker','+','Color','g');
    
    figure(10);
    plot(sliceILM(2,:), -flattenedILMe);
    hold on;

    figure(11);
    plot(sliceILM(2,1:end-1), diff(flattenedILMe) ./ diff(sliceILM(2,:)));
    hold on;

    window = 20;
    k = find(drv == leftSaddlePoint);
    while (mean(drv(k-window:k)) > 0) && (k - window > 0)
        k = k - 1;
    end

    m = find(drv == rightSaddlePoint);
    while (mean(drv(m:m+window)) < 0) && (m + window < length(drv))
        m = m + 1;
    end

    leftEdge = [flattenedILM(k) sliceILM(2, k)];
    rightEdge = [flattenedILM(m) sliceILM(2, m)];

    figure(2);
    plot(leftEdge(2), -leftEdge(1), 'Marker','+','Color','g');
    hold on;
    plot(rightEdge(2), -rightEdge(1), 'Marker','+','Color','g');

    

    leftEdge = [flattenedILM(k)+iSliceHRC(1,:) sliceILM(2, k)];
    rightEdge = [flattenedILM(m)+iSliceHRC(1,:) sliceILM(2, m)];
    foveaPit = [foveaPitY+iSliceHRC(1,:) foveaPitX];

end