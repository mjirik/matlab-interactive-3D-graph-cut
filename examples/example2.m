%% Ukazka oznaceni pixelu a pravdepodobnostni model
%  Na zaklade oznacenych pixelu jsou vytvoreny pravdepodobnostni modely
%  popredi a pozadi. Segmentace probiha jen podle nich.
% 

%% Nacteni dat
clear, clc, close all
img = imread('peppers.png');
% img = imread('cameraman.tif');
addpath(genpath('..'));
fig = figure(1);
imshow(img);
nghb = 4;

%% Oznaceni seedu
% spusteni oznacovaci funkce
% parametry jsou cislo fgury a velikost okoli
% zacina se kreslit kliknutim, konci se dalsim kliknutim
% oSeeds a bSeeds jsou seznamy bodu oznacenych pravym a levym mysitkem
[oSeeds, bSeeds] = markSeeds(fig, nghb);


%% Tvorba modelu popredi a pozadi
oS = double(selectPoints(img,oSeeds(1,:),oSeeds(2,:)));
bS = double(selectPoints(img,bSeeds(1,:),bSeeds(2,:)));

% tohle jen uk�e st�edn� hodnotu z vybran�ch oblast�

oModel = create_model(oS',3);
bModel = create_model(bS',3);

siz = size(img);

imgV = reshape(img, siz(1)*siz(2),siz(3));

oProbV = gaussK(double(imgV)', oModel.priors, oModel.mu, oModel.sigma);
bProbV = gaussK(double(imgV)', bModel.priors, bModel.mu, bModel.sigma);

oProb = reshape (oProbV, siz(1), siz(2));
bProb = reshape (bProbV, siz(1), siz(2));

%% Zobrazeni zarazeni pixelu podle verohodnosti

seg0 = oProb > bProb;
imshow(seg0);
