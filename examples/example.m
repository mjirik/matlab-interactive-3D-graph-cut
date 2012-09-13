%% Ukazka oznacovaci funkce
clear, clc
img = imread('peppers.png');
% img = imread('cameraman.tif');
addpath(genpath('..'));
fig = figure(1);
imshow(img);
nghb = 4;

% spusteni oznacovaci funkce
% parametry jsou cislo fgury a velikost okoli
% zacina se kreslit kliknutim, konci se dalsim kliknutim
% oSeeds a bSeeds jsou seznamy bodu oznacenych pravym a levym mysitkem
[oSeeds, bSeeds] = markSeeds(fig, nghb);


oS = selectPoints(img,oSeeds(1,:),oSeeds(2,:));
bS = selectPoints(img,bSeeds(1,:),bSeeds(2,:));

% tohle jen uk�e st�edn� hodnotu z vybran�ch oblast�
mos = mean(oS);
mbs = mean(bS);


