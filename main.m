clear all
close all
clc

rep = cd;
addpath([rep filesep 'SnakeKass']);
addpath([rep filesep 'SnakeKass' filesep 'PS-MAIN']);
addpath([rep filesep 'SnakeKass' filesep 'PS-SNAKES SAMPLING']);
addpath([rep filesep 'SnakeKass' filesep 'PS-MATRIX']);
addpath([rep filesep 'SnakeKass' filesep 'PS-SNAKES GVF COMMON']);

%% 

%im = im2double(imread("IMAGES/01-CABONS OD/CABONS_040.png"));
im = im2double(imread("IMAGES/04_BIM_OD/BIM_OD016.png"));
%im = im2double(imread("IMAGES/04_BIM_OD/BIM_OD021.png"));
[H, W] = size(im);

plane_H = H-104;


imp_im = im(1:plane_H, :, :);

% figure;
% imshow(imp_im);

radial_im = imp_im(:, plane_H+7:end, :);
radial_im = rgb2gray(radial_im);
%  S = graythresh(radial_im)
%  radial_im(radial_im < S) = 0;
%radial_im = histeq(radial_im);

figure;
imshow(radial_im);

[H, W] = size(radial_im);


%figure;
%imshow(radial_im);

SE = strel('disk', 10);
eroded_im = imerode(radial_im, SE);

SE = strel('disk', 2);
eroded_im = imopen(eroded_im, SE);

figure;
imshow(eroded_im);

%eroded_im = radial_im;

   eroded_im(eroded_im > graythresh(eroded_im)) = 1;
   eroded_im(eroded_im < graythresh(eroded_im)) = 0;

figure;
imshow(eroded_im);

SE = strel('disk', 40);
eroded_im = imclose(eroded_im, SE);

figure;
imshow(eroded_im);




%%

figure;
plot(imhist(radial_im));
uu = radial_im; % > graythresh(radial_im);

SE = strel('disk', 5);
uue = imopen(uu, SE);
uue = imclose(uue, SE);

uu = radial_im; %& > graythresh(radial_im);

imshow(uue);


%%
imt = radial_im;
central_profil = imt(:, W/2);
Y = diff(central_profil);

[l, pks_pos] = findpeaks(central_profil, "MinPeakProminence", 0.1) % 0.4

figure;
subplot(1, 2, 1);
plot(central_profil);
subplot(1, 2, 2);
plot(Y);

figure;
imshow(radial_im);

%% 

mode            = 1;            % 1 for edge, 2 for image (mode crêtes)(lignes), 3 for negative of image
mu              = 0.1;
nbGVFiter       = 5;
sigma           = 15;            % Standard deviation of the gaussian kernel applied to the processed image

[px,py,imEdgeMap] = GVFCompute(eroded_im, mode,mu, nbGVFiter,sigma);


% Deplay GVF field
figure; imshow(imEdgeMap); hold on;
step = 3;
[Y,X] = meshgrid(1:step:W,1:step:H);
hold on;
quiver(Y,X,px(1:step:H,1:step:W),py(1:step:H,1:step:W));

%%  Apply snake

% define parameters 
alpha       = 20; 
beta        = 15;
gamma       = 3;%Vitesse d'évolution
kappa       = 3;% Pender qlqchose
nbiter      = 50;
stepIter    = 5;
maxChange   = 0.3;

fid = figure('Name','SNAKES'); 


lineX = 20:W-20-1;
lineY = ones(1,W-40)*(pks_pos(1)-40);

%[Y,X] = GVFSnakeClose(im,px,py,Y,X, alpha,beta,gamma,kappa,nbiter,stepIter,maxChange, fid);
[Y,X] = GVFSnake(radial_im,px,py,lineX,lineY, alpha,beta,gamma,kappa,nbiter,stepIter,maxChange, fid);

v = [X';Y'];

    % plot(axons{a}(2,:),axons{a}(1,:),'r');


% plane = imp_im(:, 1:plane_H, :);
% 
% arrow_plane = plane(:,:,2) == 255 & plane(:,:,1) == 0 & plane(:,:,3) == 0 ;
% figure;
% imshow(arrow_plane);
% figure;
% imshow(plane);



% 
% function [angle] = computeAnglee(arrow_plane)
%     [H, W] = size(arrow_plane);
%     H2 = H/2;
%     W2 = W/2;
%     
%     
%     top_left = sum(arrow_plane(1:H2, 1:W2), "all")
%     top_right = sum(arrow_plane(1:H2, W2:end), "all")
% 
% 
%     bottom_left = sum(arrow_plane(H2:end, 1:W2), "all")
%     bottom_right = sum(arrow_plane(H2:end, W2:end), "all")
% 
%     grad_x = (top_right + bottom_right) - (top_left + bottom_left)
%     grad_y = (top_right + top_left) - (bottom_right + bottom_left)
%     
%     angle = atan(grad_y/grad_x);
%     angle = rad2deg(angle);
% end
% function [angle] = computeAngleee(arrow_plane)
%     
%     [m,u,Gx,Gy] = edge(arrow_plane, "prewitt"); 
%     grad_x = mean(Gx, "all")
%     grad_y = mean(Gy, "all")
%     imshow(Gx);
%     
%     angle = atan(grad_y/grad_x);
%     angle = rad2deg(angle);
% end
% 
% function [angle] = computeAngle(arrow_plane)
%     [H, W] = size(arrow_plane);
%     H2 = H/2;
%     W2 = W/2;
%     
%     figure;
%     find(sum(arrow_plane) > 0, 1, 'last');
%     
%     top_left = sum(arrow_plane(1:H2, 1:W2), "all")
%     top_right = sum(arrow_plane(1:H2, W2:end), "all")
% 
% 
%     bottom_left = sum(arrow_plane(H2:end, 1:W2), "all")
%     bottom_right = sum(arrow_plane(H2:end, W2:end), "all")
% 
%     grad_x = (top_right + bottom_right) - (top_left + bottom_left)
%     grad_y = (top_right + top_left) - (bottom_right + bottom_left)
%     
%     angle = atan(grad_y/grad_x);
%     angle = rad2deg(angle);
% end
