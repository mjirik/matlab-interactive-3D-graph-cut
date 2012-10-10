%% Ukazka segmentace pomoci Grapg-Cut 3D s pevnymi uzly, N-linky z hran
% Oznacene pixely jsou pouzty pro modelovani barvy objektu a pozadi. Jsou
% nastaveny pevna spojeni s uzly. T-linky jsou nastaveny pomoci
% pravdepodobnostnich modelu, N-linky jsou nastaveny na zaklade hranovych
% operatoru.

clear, clc, close
tic

% Cesta ke GMM - nástroj pro modelování gaussovských směsí
%     http://lasa.epfl.ch/sourcecode/index.php
addpath('../outsource/gmm/');


% Cesta k matlab wrapperu C funkce graph-cut 
% Implementace gc v jazyce C
%     http://www.csd.uwo.ca/~olga/code.html
% Matlab wrapper
%     http://vision.ucla.edu/~brian/gcmex.html
addpath('../outsource/gc_veksler/');
addpath('../gauss_tools/');
addpath('../gui_tools/');

lambda = 30.0;
nghb = 4;
filtsize = [13 13];
almostzero = 1e-50;
K = lambda*4+1;
K = 200;
smK = 1;
ng = 1;
sliceN = 10;


%% Nacitani dat
load mri
% data maji velikost [128 128 1 27], takze je potreba je upravit
img3d = reshape(D,[size(D,1), size(D,2), size(D,4)]);

sz = size(img3d);
img = img3d(:,:,sliceN);


% %% Oznaceni seedu
% 
% fig = figure(1);
% imshow(img);
% 
% 
% % spusteni oznacovaci funkce
% % parametry jsou cislo fgury a velikost okoli
% % zacina se kreslit kliknutim, konci se dalsim kliknutim
% % oSeeds a bSeeds jsou seznamy bodu oznacenych pravym a levym mysitkem
% [oSeeds, bSeeds oSeedsIm, bSeedsIm] = markSeeds(fig, nghb);
% 
% 
% %% Tvorba modelu
% oS = double(selectPoints(img,oSeeds(1,:),oSeeds(2,:)));
% bS = double(selectPoints(img,bSeeds(1,:),bSeeds(2,:)));
% 
% % tohle jen ukaze stredn hodnotu z vybranych oblasti
% 
% oModel = create_model(oS',ng);
% bModel = create_model(bS',ng);
% 
% siz = size(img);
% 
% imgV = reshape(img3d, sz(1)*sz(2)*sz(3),[]);
% 
% oProbV = gaussK(double(imgV)', oModel.priors, oModel.mu, oModel.sigma);
% bProbV = gaussK(double(imgV)', bModel.priors, bModel.mu, bModel.sigma);

oProb = img3d;
bProb = 90 - img3d;

seg0 = oProb > bProb;


%% Stanoveni vah N-linku
% vypocet vah
% lambda = 37.8;

Sc = [ 0, lambda; lambda,0];

% 
% 
% % tvar hranoveho detektoru
% % Edge terms
% g = fspecial('gauss', filtsize, 2);
% dy = fspecial('sobel');
% vf = conv2(g, dy, 'valid');
% 
% if(length(siz) == 3)
%     imgray = rgb2gray(img);
% else
%     imgray = img;
% end
% Vc1 = zeros(size(imgray));
% Hc1 = Vc1;
% Hc2 = Vc1;
% Vc2 = Vc1;
% Vc = Vc1;
% Hc = Vc1;
% 
% % Vc1 = abs(imfilter(dc(:,:,1), vf, 'symmetric'));
% % Hc1 = abs(imfilter(dc(:,:,1), vf', 'symmetric'));
% % Vc2 = abs(imfilter(dc(:,:,2), vf, 'symmetric'));
% % Hc2 = abs(imfilter(dc(:,:,2), vf', 'symmetric'));
% Vc = abs(imfilter(imgray, vf, 'symmetric'));
% Hc = abs(imfilter(imgray, vf', 'symmetric'));



%% Stanoveni vah T-linku
% oProbLog = log(oProb+almostzero);
% bProbLog = log(bProb+almostzero);
% 
% % nejmensi minimum, aby to bylo kladne, ale odecitalo se porad stejne
% minoffset  = min(min(oProbLog(:)), min(bProbLog(:)));
oProbLog = oProb;% - minoffset;
bProbLog = bProb;% - minoffset;

% pevne spojeni s s a t
% nastavime nuly tam kde jsou pixely oznaceny
% oProbLog = oProbLog .* (1 - oSeedsIm) .* (1 - bSeedsIm);
% bProbLog = bProbLog .* (1 - bSeedsIm) .* (1 - oSeedsIm);
objW = oProbLog;% + K.*oSeedsIm;
bckW = bProbLog;% + K.*bSeedsIm;

Dc = cat(4, objW,bckW );


%% Rez grafem
tic
gch = GraphCut('open', Dc, Sc );%, exp(-1*smK*Vc), exp(-1*smK*Hc));
% gch = GraphCut( 'open', Dc, Sc );
[gch L] = GraphCut( 'expand', gch );
gch = GraphCut( 'close', gch );

L = reshape(L,sz);
%% Vykresleni vysledku
% nove vykresleni obrazku - je tak videtkolik se toho nacetlo

% jako co je nas obrazek
% label = 1;
% 
% lb=(L==label) ;
% lb=imdilate(lb,strel('disk',1))-lb ; 
% hold on; contour(lb,[1 1],'g') ; hold off ;
toc

figure, isosurface(L,0), axis equal, view(3)