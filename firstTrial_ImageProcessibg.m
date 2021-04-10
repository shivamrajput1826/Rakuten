%clc;
%clear all;
close all;
%% Select the Image
a = imread('01_h.jpg');
%Sigma = 1;
options = struct;
options.FrangiScaleRange = [1 8];
options.FrangiScaleRatio = 1;
options.FrangiBetaOne = 1;
options.FrangiBetaTwo = 2;
options.BlackWhite = true;
options.verbose = true;
%% Extraction of green channel
n =  size(a);
I(1:n(1), 1:n(2)) = a(:,:,2);
% r = imhist(green);
% imshowpair(a, I, 'montage');
% I1 = imadjust(I, stretchlim(I), []); % can be mixed later
% I1 = histeq(I);
I1 = adapthisteq(I); %CLAHE Technique 
I2 = imbilatfilt(I1);
I2 = imopen(I2, strel('disk', 3, 8));
% imshowpair(I1, I2, 'montage');
%I2 = rgb2gray(I2);

%% Background Exclusion
% blurredimage  = imfilter(I2,ones(9)/81, 'symmetric');
% I2 = I2 - blurredimage;
% se = strel('disk', 8);
% I2 = imtophat(I1, 1,se);
% % Imr = imresize(I2, [344 540]);
% % Imbg = imfilter(Imr, ones(69)/(69*69), 'symmetric');
% % sel = strel('disk', 3,8);
% % Imgama = imopen(Imr, sel);
% % Imd = Imgama - Imbg;
% % 
% % I2 = imresize(Imr-Imd, [2336, 3504]);
aAvg = (a(:,:,1) + a(:,:,2) + a(:,:,3))/3;
d = abs(a(:,:,1) - a(:,:,2)) + abs(a(:,:,2) - a(:,:,3)) + abs(a(:,:,3) - a(:,:,1));

mask = (aAvg<40) & (d<50);
% I2 = max(I2 -   256*uint8(mask), 0);

%% Resolution hierarchy: rescalling by factor 0.5 (two times)
I_1resize = imresize(I2, 0.5, 'bilinear');
I_2resize = imresize(I_1resize, 0.5, 'bilinear');
I_3resize = imresize(I_2resize, 0.5, 'bilinear');
%% Hessian vesselness extraction
[outIm1] = FrangiFilter2D(double(I2), options);
[outImextra] = FrangiFilter2D(double(I), options);

options.FrangiScaleRange = [1 4];
options.FrangiScaleRatio = 1;
[outIm2] = FrangiFilter2D(double(I_1resize), options);

options.FrangiScaleRange = [1 2];
options.FrangiScaleRatio = 1;
[outIm3] = FrangiFilter2D(double(I_2resize), options);

options.FrangiScaleRange = [0.5 1.5];
options.FrangiScaleRatio = 0.5;
[outIm4] = FrangiFilter2D(double(I_3resize), options);

%Scaling back to orignal
outIm2 = imresize(outIm2, 2, 'bilinear');
outIm3 = imresize(outIm3, 4, 'bilinear');
outIm4 = imresize(outIm4, 8, 'bilinear');
%% Hystersis Threshold and fusion of image binarization
% thres1 = isodata(outIm1);
% BW1 = imbinarize(outIm1, thres1);
% thres2 = isodata(outIm2);
% BW2 = imbinarize(outIm2, thres2);
% thres3 = isodata(outIm3);
% BW3 = imbinarize(outIm3, thres3);
% thresextra = isodata(outImextra);
% BWextra = imbinarize(outImextra, thresextra);
% thres4 = isodata(outIm4);
% BW4 = imbinarize(outIm4, thres4);

[BW1]=hysteresis3d(outIm1,0.85,0.3,8);
[BW2]=hysteresis3d(outIm2,0.85,0.3,8);
[BW3]=hysteresis3d(outIm3,0.85,0.3,8);
[BWextra]=hysteresis3d(outImextra,0.85,0.3,8);
[BW4]=hysteresis3d(outIm4,0.85,0.3,8);

%% Post Processing
SE = strel('disk', 6,8);
BWgjb1 = bwareaopen(BW1, 20000);
BWgjb1 = imclose(BWgjb1, SE);
BWgjb2 = bwareaopen(BW2, 400000);
BWgjb2 = imclose(BWgjb2, SE);
BWgjb3 = bwareaopen(BW3, 40000);
BWgjb3 = imclose(BWgjb3, SE);
BWgjbextra = bwareaopen(BWextra, 10000);
BWgjbextra = imclose(BWgjbextra, SE);
BWgjb4 = bwareaopen(BW4, 60000);
BWgjb4 = imclose(BWgjb4, SE);
outBWgjb = imbinarize((BWgjb1 + BWgjb2 + BWgjb3 + BWgjbextra), 2); % + BWgjb4, 0);
%outBWgjb = imbinarize((BWgjb1 + BWgjb2 + BWgjbextra), 1); % + BWgjb4, 0);
% outBWgjb = imfill(outImgjb, 0, 4);
outImgjb = bwmorph(outBWgjb, 'open', Inf);

%% Represnting Obtained figures

figure;
outImgjb = max(outImgjb - mask, 0);
imshow(outImgjb);
figure; imshowpair(a, outImgjb, 'montage');