clear all
close all
clc

rep = cd;
addpath([rep filesep 'SnakeKass']);
addpath([rep filesep 'SnakeKass' filesep 'PS-MAIN']);
addpath([rep filesep 'SnakeKass' filesep 'PS-SNAKES SAMPLING']);
addpath([rep filesep 'SnakeKass' filesep 'PS-MATRIX']);
addpath([rep filesep 'SnakeKass' filesep 'PS-SNAKES GVF COMMON']);

%% Import Data
% ---------------------------------------------------------------
inputPath = "IMAGES";
outputILMPath = "Segmentations/ILM/";

% patientFolders = ["IMAGES/01-CABONS OD",...
%                   "IMAGES/02_DEA_OD", ...
%                   "IMAGES/04_BIM_OD", ...
%                   "IMAGES/08_TRK_OD", ...
% ];
patientFolders = dir(fullfile(inputPath, '0*'));
patientFolders = { patientFolders.name };

% For each patient
% -----------------------------------
for patientFolder=patientFolders
    currenDir = strcat(inputPath, "/", patientFolder{1});

    fileList = dir(fullfile(currenDir, '*.png'));
    fileList = {fileList.name};

    slicesILM = {};
    
    % For each file
    % -----------------------------------
    i = 1;
    for file=fileList
        im = im2double(imread(strcat(currenDir, "/", file)));
         
        % Temporary draft in order to extract the relevant part of the image
        % IMPORTANT: THIS NEED TO BE REPLACED WITH A PROPER FUNCTION
        [H, W] = size(im);
        plane_H = H-104;
        imp_im = im(1:plane_H, :, :);
        radial_im = imp_im(:, plane_H+7:end, :);
        radial_im = rgb2gray(radial_im);
        
        % Segmenting the ILM
        sliceILM = extractILM(radial_im, false, []);
        
        figure;
        imshow(radial_im);
        hold on;
        plot(sliceILM(2,:), sliceILM(1,:));
        
        slicesILM{end+1} = sliceILM;

        fprintf("File Number %d Completed\n", i);
        i = i + 1;
    end

    outputILMFileName = strcat(outputILMPath, "slicesILM_", patientFolder, ".mat");
    save(outputILMFileName, "slicesILM");

    fprintf("Patient %s Completed", patientFolder{1});
end



