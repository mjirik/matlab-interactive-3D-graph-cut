%% Priklad segmentace pomoci GC v sedotonovem 2D
clear, close, clc

addpath(genpath('..'));



%% Nacitani dat
img = imread ('cameraman.tif');


%% zpracovani
[segmentation,seeds] = gc_interactive(img);


%% Vizualizace
 m3DSeedEditor(img,'labels', segmentation, 'seeds',seeds)