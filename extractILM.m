

function [slice] = extractILM(img, afficheMode)
    [H, W] = size(img);
    
    [segmentedImg] = preprocessILM(img);
    
    % Compute the left and right boundries of the IMT coutours
    %----------------------------------------------------
    cumulative_horizontal_profil = sum(segmentedImg, 1);
    bound_left = find(cumulative_horizontal_profil, 1, "first");
    bound_right = W - find(flip(cumulative_horizontal_profil), 1, "first");


    % Define the anchor points of the active contours;
    %----------------------------------------------------
    [yleft, yfirst_quartile, ...
     ycenter, ythird_quartile, yright] = defineAnchorPoints(segmentedImg, bound_left, bound_right);
    

    % Color the pixel belows white <-----------------------------
    %----------------------------------------------------
    segmentedImg = colorPixelsBelowWhite(segmentedImg);


    % Apply GVF
    %---------------------------------------
    mode            = 1;            
    mu              = 0.1;
    nbGVFiter       = 5;
    sigma           = 3;            
    
    [px,py, l] = GVFCompute(segmentedImg, mode,mu, nbGVFiter,sigma);
    

    % Apply Snakes
    %---------------------------------------
    step = 18;
    offset = ceil(bound_right/step) - (floor(bound_right/step/4)*4);
    
    % Initialise the initial contour
    lineX = 1:step:bound_right;
    lineY = [
        linspace(yleft, yfirst_quartile, (bound_right/step) /4), ...
        linspace(yfirst_quartile, ycenter, (bound_right/step) /4), ...
        linspace(ycenter, ythird_quartile, (bound_right/step) /4), ...
        linspace(ythird_quartile, yright, offset + (bound_right/step) /4 )
    ];
    
    slice = applyActiveContours(img, px, py, lineX, lineY, afficheMode);
end

function [segmentedImg] = preprocessILM(img)
    
    % Remove noises from the OCT image
    %------------------------------
    filteredImg = wiener2(img,[20 20]);
    
    % Smoothing the image
    %------------------------------
    SE_opening = strel('disk', 2);
    SE_closing = strel('disk', 19); %15

    morphedImg = imopen(filteredImg, SE_opening);
    morphedImg = imclose(morphedImg, SE_closing);
    
    % Applying an Otsu threshold
    %------------------------------
    thresh = graythresh(morphedImg);
    %segmentedImg(seg_im > graythresh(seg_im)) = 1;
    %segmentedImg(seg_im < graythresh(seg_im)) = 0;
    segmentedImg = imbinarize(morphedImg, thresh);

    % Fill any hole that can be found on the image
    %------------------------------
    segmentedImg = imfill(segmentedImg,'holes');
end

function [slice] = applyActiveContours(img, px, py, lineX, lineY, afficheMode)
    

    % define parameters 
    alpha       = 10; 
    beta        = 15;
    gamma       = 3;%Vitesse d'évolution
    kappa       = 3;% Pender qlqchose
    nbiter      = 200;
    stepIter    = 50;
    maxChange   = 0.5;
    
    if afficheMode
        fid = figure('Name','SNAKES'); 
        [Y,X] = GVFSnake(img,px,py,lineX,lineY, alpha,beta,gamma,kappa,nbiter,stepIter,maxChange, fid);
    else 
        [Y,X] = GVFSnake(img,px,py,lineX,lineY, alpha,beta,gamma,kappa,nbiter,stepIter,maxChange);
    end

    slice = [X';Y'];
end

function [yleft, yfirst_quartile, ycenter, ...
    ythird_quartile, yright] = defineAnchorPoints(segmentedImg, bound_left, bound_right)
    
    BL = bound_left;
    BR = bound_right;
    BR2 = round(BR/2);
    BR4 = round(BR/4);
    window = 20;

    left_profil = mean(segmentedImg(:, 1:window), 2);
    right_profil = mean(segmentedImg(:, BR-window+1:BR), 2);
    central_profil = mean(segmentedImg(:, BR2-window:BR2+window), 2);
    
    first_quartile_profil = mean(segmentedImg(:, BR4-window:BR4+window), 2);
    third_quartile_profil = mean(segmentedImg(:, 3*BR4-window:3*BR4+window), 2);
    
    
    yleft = find(left_profil, 1, "first"); %The first-non zero value
    ycenter = find(central_profil, 1, "first");
    yright = find(right_profil, 1, "first");
    yfirst_quartile = find(first_quartile_profil, 1, "first");
    ythird_quartile = find(third_quartile_profil, 1, "first");
end

function [segmentedImg] = colorPixelsBelowWhite(img)
    segmentedImg = img;

    whitePixels = find(segmentedImg == 1); 
    
    for i = 1:numel(whitePixels)
        [row, col] = ind2sub(size(segmentedImg), whitePixels(i));
        segmentedImg(row+1:end, col) = 255;
    end
end


