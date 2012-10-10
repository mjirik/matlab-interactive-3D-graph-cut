%% Priklad segmentace pomoci GC ve 3D
clear, close, clc
%load('imAndSeeds')
addpath(genpath('..'));
%addpath('/home/tomas/queetech/graphcut/src/matlab/outsource/gc_veksler/');


%% Nacitani dat
% qpath = getenv('QDATA_PATH');
% dataPath = [qpath '/' 'jatra-kma/jatra_5mm'];
% %        dicomreaddir
% img3d = dicomreaddir(dataPath);
load mri;
img3d = reshape(D,siz);

%% zpracovani
[segmentation,seeds] = gc_interactive(img3d,'lambda',3);


%% Vizualizace
 m3DSeedEditor(img3d,'labels', segmentation, 'seeds',seeds)