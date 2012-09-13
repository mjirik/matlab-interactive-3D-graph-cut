%% Priklad segmentace pomoci GC ve 3D
clear, close, clc
%load('imAndSeeds')
addpath(genpath('..'));
%% Parametry algoritmu
lambda = 3.0;
nghb = 4;
filtsize = [13 13];
almostzero = 1e-50;
K = lambda*4+1;
K = 200;
smK = 1;
ng = 2;
sliceN = 10;
scale = 1;


%% Nacitani dat
% qpath = getenv('QDATA_PATH');
% dataPath = [qpath '/' 'jatra-kma/jatra_5mm'];
% %        dicomreaddir
% img3d = dicomreaddir(dataPath);
load mri;
img3d = reshape(D,siz);

%zmenseni 
img3d = int16(img3d);
sz = size(img3d);

%% zmenseni

img3d = imresize(img3d, scale);
%img3d = img3d(1:4:end,1:4:end,:);
%seeds = seeds(1:4:end,1:4:end,:);


%% Oznaceni seedu



% spusteni oznacovaci funkce
% parametry jsou cislo fgury a velikost okoli
% zacina se kreslit kliknutim, konci se dalsim kliknutim
% oSeeds a bSeeds jsou seznamy bodu oznacenych pravym a levym mysitkem




seeds = int8(viewerGUI2((img3d)));




sz = size(img3d);
%% Tvorba modelu
tic;
oS = double(img3d(seeds == 1));
bS = double(img3d(seeds ==-1));
% oS = double(selectPoints(img,oSeeds(1,:),oSeeds(2,:)));
% bS = double(selectPoints(img,bSeeds(1,:),bSeeds(2,:)));

% tohle jen ukaze stredn hodnotu z vybranych oblasti

oModel = create_model(oS',ng);
bModel = create_model(bS',ng);

imgV = reshape(img3d, sz(1)*sz(2)*sz(3),[]);

oProbV = gaussK(double(imgV)', oModel.priors, oModel.mu, oModel.sigma);
bProbV = gaussK(double(imgV)', bModel.priors, bModel.mu, bModel.sigma);

oProb = reshape(oProbV, sz);
bProb = reshape(bProbV, sz);

seg0 = oProb > bProb;

clear ('oProbV', 'bProbV','imgV','oS','bS');
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
oProbLog = -log(oProb+almostzero);
bProbLog = -log(bProb+almostzero);
clear ('oProb', 'bProb');
% 
% % nejmensi minimum, aby to bylo kladne, ale odecitalo se porad stejne
% minoffset  = min(min(oProbLog(:)), min(bProbLog(:)));
% oProbLog = oProbLog - minoffset;
% bProbLog = bProbLog - minoffset;

% pevne spojeni s s a t
% nastavime nuly tam kde jsou pixely oznaceny
%oProbLog = oProbLog .* (1 - oSeedsIm) .* (1 - bSeedsIm);
%bProbLog = bProbLog .* (1 - bSeedsIm) .* (1 - oSeedsIm);
oProbLog = oProbLog .* (seeds == 0);
bProbLog = bProbLog .* (seeds == 0);

objW = oProbLog + K.*(seeds == -1);
bckW = bProbLog + K.*(seeds == 1);

clear ('oProbLog', 'bProbLog');
Dc = cat(4, bckW,objW );
clear ('bckW', 'objW');
disp ('Jasovy model ')
toc

%% Rez grafem
tic
gch = GraphCut('open', Dc, Sc );%, exp(-1*smK*Vc), exp(-1*smK*Hc));
% gch = GraphCut( 'open', Dc, Sc );
[gch L] = GraphCut( 'expand', gch );
gch = GraphCut( 'close', gch );

L = uint8(reshape(L,sz));
%% Vykresleni vysledku
% nove vykresleni obrazku - je tak videtkolik se toho nacetlo

% jako co je nas obrazek
% label = 1;
% 
% lb=(L==label) ;
% lb=imdilate(lb,strel('disk',1))-lb ; 
% hold on; contour(lb,[1 1],'g') ; hold off ;
disp('Rez grafem');
toc

figure, isosurface(L,0), axis equal, view(3)

% zvetseni zpet
% img3d = imresize(img3d,1/scale);
% L = imresize(L,1/scale,'nearest');
% seeds = imresize(seeds,1/scale,'nearest');

viewerGUI2(img3d,'labels',uint8(L),'seeds',seeds)