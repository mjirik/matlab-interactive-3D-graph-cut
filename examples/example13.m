%% Priklad segmentace pomoci GC
clear, close, clc

addpath(genpath('..'));



%% Nacitani dat
[filename, pathname]=uigetfile('*.*','Pick a image file');
img = imread (fullfile(pathname, filename));


%% zpracovani
[segmentation,seeds] = gc_interactive(img);


%% Vizualizace
 m3DSeedEditor(img,'labels', segmentation, 'seeds',seeds)