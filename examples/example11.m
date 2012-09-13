%% Priklad segmentace pomoci GC ve 3D
clear, close, clc
%load('imAndSeeds')
addpath(genpath([getenv('QPRJ_QUEETECH') '/graphcut/']))
addpath(genpath('..'));

%% Nacitani dat
qpath = getenv('QDATA_PATH')
dataPath = [qpath '/' 'jatra-kma/jatra_5mm'];
dataPath = [qpath '/' 'jatra-kma/jatra_06mm_jenjatra'];
dataPath = [qpath '/' 'jatra_5mm_jenjatra'];
% dataPath = [qpath '/' 'jatra-kma/justone_region_final_for_skeleton'];
% dataPath = [qpath '/' 'jatra-kma/features_k5_06mm_5filtered'];

% %        dicomreaddir
img3d = dicomreaddir(dataPath,'DataType','int16');

%% zpracovani
[segmentation,seeds] = gc_interactive(img3d,'lambda',3, 'ng',3,'scale',0.25);


%% Vizualizace
viewerGUI2(img3d,'labels', segmentation, 'seeds',seeds)
