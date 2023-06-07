

im1 = im2double(imread("IMAGES/04_BIM_OD/BIM_OD016.png"));
im2 = im2double(imread("IMAGES/04_BIM_OD/BIM_OD017.png"));

[H, W] = size(im1);
plane_H = H-104;
im1 = im1(1:plane_H, :, :);
im1 = im1(:, plane_H+7:end, :);
im1 = rgb2gray(im1);

[H, W] = size(im2);
plane_H = H-104;
im2 = im2(1:plane_H, :, :);
im2 = im2(:, plane_H+7:end, :);
im2 = rgb2gray(im2);

anchors = cat(3, ...
    [540 140; 750 175; 900 150], ...
    [741 52; 680 250; 747 360] ...
);
    %[540-300 140; 750-300 175; 900-300 150] ...

anchor1 = [ [540 140];[750 175]; [900 150]];
%anchor2 = [ [540-300 140];[750-300 175]; [900-300 150]];
anchor2 = [[741 52] ;[680 250]; [747 360]];


[slices, testNewAnchor2] = applyRecalibrationTEST({im1 im2}, anchors);
figure;
subplot(2,1, 1);
imshow(im1);
hold on;
plot(anchor1(:,1), anchor1(:,2), 'Marker','+');

subplot(2,1, 2);
imshow(im2);
hold on;
plot(anchor2(:,1), anchor2(:,2), 'Marker', '+');
% -- -- 
figure;
subplot(2,1,1);
imshow(slices{1});
hold on;
plot(anchor1(:,1), anchor1(:,2), 'Marker','+');

subplot(2,1,2);
imshow(slices{2});
hold on;
plot(testNewAnchor2(:,1), testNewAnchor2(:,2), 'Marker', '+');



% -------------------------------------------------------------------------
% applyRecalibration - Calibrate images provided with a set of ancherPoints
%
%   slices      : array of 48 source images in gray-level
%   anchorPoints: array of 48 3D-vectors containing 2D coordinates 
%                 defined as such: [ leftRim, centerPit, rightRim]
%                 > Coordinates are pixel defined, example [1249px, 427px] 
% -------------------------------------------------------------------------

function [resultSlices, testOutputArray] = applyRecalibrationTEST(slices, recalibrationPoints)
    
    anchorPoints = reshape(recalibrationPoints(:,:,1), [3 2]);
    firstSlice = slices{1};
    resultSlices = {firstSlice};

    for i=2:length(slices)
        movingPoints = reshape(recalibrationPoints(:,:,i), [3 2]);

%         original_points = movingPoints; ;%[x1, y1; x2, y2; x3, y3];
%         target_points = anchorPoints;%[x1', y1'; x2', y2'; x3', y3'];
%         
%         diffs = target_points - original_points;
%         
%         a = mean(diffs(:, 1)) / mean(diffs(:, 2));
%         b = -1 / a;
%         if b == 0
%             a = 1;
%         end
%         tx = mean(target_points(:, 1)) - mean(original_points(:, 1));
%         ty = mean(target_points(:, 2)) - mean(original_points(:, 2));
%         
%         T = [a, -b, tx;
%              b, a, ty;
%              0, 0, 1];
%         
%         
%         recalibratedImage = imwarp(slices{i}, affine2d(T'), 'OutputView', imref2d(size(slices{i})));
% 
%         pointsHomogeneous = [original_points, ones(size(original_points, 1), 1)];
%         transformedPointsHomogeneous = pointsHomogeneous * T';
%         testOutputArray = transformedPointsHomogeneous(:, 1:2);
% 
%         resultSlices{end+1} = recalibratedImage;
%         anchorPoints = movingPoints; % Est ce une bonne idée ?


%         % Calculate translations
%         translation = mean(destinationPoints - sourcesPoints);
%         
%         % Calculate rotations
%         theta = atan2(destinationPoints(:,2) - mean(destinationPoints(:,2)), destinationPoints(:,1) - mean(destinationPoints(:,1))) - ...
%                 atan2(sourcesPoints(:,2) - mean(sourcesPoints(:,2)), sourcesPoints(:,1) - mean(sourcesPoints(:,1)));
%         meanTheta = mean(theta);
%         meanTheta = rad2deg(meanTheta);
%         
%         % Recalibrate the distorted image using translations and rotations
%         rotatedImage = imrotate(slices{i}, -meanTheta, 'bilinear', 'crop');
%         recalibratedImage = imtranslate(rotatedImage, -translation);


        tform = fitgeotrans(movingPoints, anchorPoints, 'nonreflectivesimilarity');

        recalibratedImage = imwarp(slices{i}, tform, 'OutputView', imref2d(size(slices{i})));

    
        pointsHomogeneous = [movingPoints, ones(size(movingPoints, 1), 1)];
        transformedPointsHomogeneous = pointsHomogeneous * tform.T;
        testOutputArray = transformedPointsHomogeneous(:, 1:2);

        resultSlices{end+1} = recalibratedImage;
        anchorPoints = movingPoints; % Est ce une bonne idée ?
    end
end

