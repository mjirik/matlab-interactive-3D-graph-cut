%% Priklad segmentace pomoci GC v barevnem 2D
clear, close, clc

addpath(genpath('..'));



%% Nacitani dat
% img = imread ('cameraman.tif');
img = imread('peppers.png');

%% zpracovani
[segmentation,seeds] = gc_interactive(img);


%% Vizualizace
 m3DSeedEditor(rgb2gray(img),'labels', segmentation, 'seeds',seeds)