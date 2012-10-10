%% Ukazka segmentace pomoci Grapg-Cut bez pevnych uzlu, N-linky - hrany
% interaktivní segmentace
% Oznacene pixely jsou pouzty pro modelovani barvy objektu a pozadi. Jsou
% nastaveny pevna spojeni s uzly. T-linkyd jsou jen pomoci hardlinku
% pravdepodobnostnich modelu, N-linky jsou vytvareny na zaklade hranovych
% operatoru

clear, clc, close all

% Cesta ke GMM - nástroj pro modelování gaussovských směsí
%     http://lasa.epfl.ch/sourcecode/index.php
addpath('../outsource/gmm/');
% addpath(pathgen('..'));

% Cesta k matlab wrapperu C funkce graph-cut 
% Implementace gc v jazyce C
%     http://www.csd.uwo.ca/~olga/code.html
% Matlab wrapper
%     http://vision.ucla.edu/~brian/gcmex.html
addpath('../outsource/gc_veksler/');
addpath('../gauss_tools/');
addpath('../gui_tools/');

%% Nacteni dat

% addpath('../../../../sample_data/');
% img = imread('tumor2.jpg');


% img = imread('cameraman.tif');
% img = imread('peppers.png');
%  img = imread('canoe.tif');
% img = imread('football.jpg');
% img = imread('f:\Download\Com604-1-14-v2.jpg');
% img = imread('f:\My Dropbox\Work\LevelSets\twocells.bmp');
% img = imread('office_6.jpg');
%  img = imread('pillsetc.png');

 img = imread('pears.png');
% img = imread('f:\images\tumor2.jpg');

% img = dicomread('f:\Work\DATA BENDY\1\DICOM\10092309\40320000\09562866');

% imshow(a,'DisplayRange',[]);

 img = im2double(img);

fig = figure(1);
imshow(img,'DisplayRange',[]);
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

% tohle jen ukaze stredni hodnotu z vybranech oblasti
oModel = create_model(oS',3);
bModel = create_model(bS',3);

siz = size(img);

% osetreni RGB
if(length(siz) == 3)
    imgV = reshape(img, siz(1)*siz(2), siz(3));
else
    imgV = reshape(img, siz(1)*siz(2), 1);
end

oProbV = gaussK(double(imgV)', oModel.priors, oModel.mu, oModel.sigma);
bProbV = gaussK(double(imgV)', bModel.priors, bModel.mu, bModel.sigma);

oProb = reshape (oProbV, siz(1), siz(2));
bProb = reshape (bProbV, siz(1), siz(2));

seg0 = oProb > bProb;

%% Nastaveni vah pro T-linku pro GC

% Vypocet vah
oProbLog = log(oProb+1e-50);
bProbLog = log(bProb+1e-50);

% nejmensi minimum, aby to bylo kladne, ale odecitalo se porad stejne
minoffset  = min(min(oProbLog(:)), min(bProbLog(:)));
oProbLog = oProbLog - minoffset;
bProbLog = bProbLog - minoffset;

Dc = cat(3, oProbLog, bProbLog);

% Nastaveni hardlinku

%  DDc = Dc; % 
% jen hardlinky, model se ignoruje
DDc=zeros(size(Dc));
for(i = 1:size(oSeeds,2))
    DDc(oSeeds(1,i),oSeeds(2,i),1) = 999;
    DDc(oSeeds(1,i),oSeeds(2,i),2) = 0;
end

for(i = 1:size(bSeeds,2))
    DDc(bSeeds(1,i),bSeeds(2,i),1) = 0;
    DDc(bSeeds(1,i),bSeeds(2,i),2) = 999;
end


%% Nastaveni vah N-linku pro GC

Sc = [ 0, 20; 20,0];

% tvar hranoveho detektoru
% Edge terms
g = fspecial('gauss', [13 13], 2);
dy = fspecial('sobel');
vf = conv2(g, dy, 'valid');

if(length(siz) == 3)
    imgray = rgb2gray(img);
else
    imgray = img;
end
Vc1 = zeros(size(imgray));
Hc1 = Vc1;
Hc2 = Vc1;
Vc2 = Vc1;
Vc = Vc1;
Hc = Vc1;

% Vc1 = abs(imfilter(dc(:,:,1), vf, 'symmetric'));
% Hc1 = abs(imfilter(dc(:,:,1), vf', 'symmetric'));
% Vc2 = abs(imfilter(dc(:,:,2), vf, 'symmetric'));
% Hc2 = abs(imfilter(dc(:,:,2), vf', 'symmetric'));
Vc = abs(imfilter(imgray, vf, 'symmetric'));
Hc = abs(imfilter(imgray, vf', 'symmetric'));

%% Volani Graph-Cut

% Dc1 = simill1;
% Dc2 = simill2;
% Dccc = cat(3,Dc1,Dc2);
% gch = GraphCut( 'open', Dcc, Sc );

gch = GraphCut('open', DDc, Sc , exp(-10*Vc), exp(-10*Hc));
[gch L] = GraphCut('expand', gch);

gch = GraphCut('close', gch);

% gch = GraphCut( 'open', Dc, Sc );
% [gch L] = GraphCut( 'expand', gch );
% gch = GraphCut( 'close', gch );

%% Vykresleni vysledku

% jako co je nas obrazek
label = 1;

lb=(L==label) ;
lb=imdilate(lb,strel('disk',1))-lb ; 
hold on; contour(lb,[1 1],'r') ; hold off ;
