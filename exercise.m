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