%% SKRIPT PRO SEGMENTACI OBRAZU METODOU GRAPH CUT
% pouzita implementace GC od Olgy Veksler http://www.csd.uwo.ca/~olga/code.html
% wrapper napsal Brian Fulkerson http://vision.ucla.edu/~brian/gcmex.html
fprintf('****  SEGMENTACE POMOCI METODY GRAPH CUT  ****\n')

%% INICIALIZACE
clear, clc, close
fprintf('inicializace...')
addpath('../../../../sample_data/');
qdataPath = getenv('QDATA_PATH');

% img = imread('tumor2.jpg');
img = imread('football.jpg');
% img = imread('mozek.jpg');
% img = imread('f:\Download\images\mozek1.png');

% filename = strcat(qdataPath, '\Jatra-tumory\1\tumors\09586107');

% img = dicomread(filename);
nghb = 4; %nastavi velikost sousedstvi
numGauss = 3; %pocet gausovek v gausovske smesi 
model = 'gmm';
segmentationType = 'grow'; %pokud chceme potlacit data term (t-linky)-jde pouze o "narust" oblasti
if(strcmp(segmentationType,'grow'))
    lambda = 1; %parametr pro vazeni boundary a region pristupu v cost function
    hardCons = 9999; %urcuje kapacitu seedu ke "svemu" terminalu (objekt. seedu a zdroje / seedu poz. a stoku)
else
    lambda = 0.00001;
    hardCons = 99999;
end

img = im2double(img);

if(ndims(img) == 3)
    img = rgb2gray(img);
end

siz = size(img);

fig = figure(1);
imshow(img,'DisplayRange',[]);

% Cesta k matlab wrapperu C funkce graph-cut
addpath('../outsource/gc_veksler/');
addpath('../gauss_tools/');
addpath('../gui_tools/');

% Cesta ke GMM - nastroji pro modelovani gaussovskych smesi
%     http://lasa.epfl.ch/sourcecode/index.php
addpath('../outsource/gmm/');
fprintf('hotovo\n')

%% OZNACENI SEEDU
% parametry jsou cislo figury a velikost okoli
% zacina se kreslit kliknutim, konci se dalsim kliknutim
% oSeeds a bSeeds jsou seznamy bodu oznacenych pravym a levym mysitkem
fprintf('oznacovani seedu...')
[oSeeds, bSeeds] = markSeeds(fig, nghb);
fprintf('hotovo\n')

%selectPoints - vrati seznam bodu jako dlouhy vektor
oS = double(selectPoints(img,oSeeds(1,:),oSeeds(2,:)));
bS = double(selectPoints(img,bSeeds(1,:),bSeeds(2,:)));

if(length(siz) == 3)
    imgV = reshape(img, siz(1)*siz(2), siz(3));
else
    imgV = reshape(img, siz(1)*siz(2), 1);
end

%% DATA TERM
%pocitani vah t-linek
if(~strcmp(segmentationType,'grow'))
    oProb = [];
    bProb = [];
    fprintf('pocitani data termu (t-linky)...')
    if(strcmp(model,'kde'))% vypocita model objektu a pozadi jako kernel density estimation
        fprintf('kernel density estimation...')
        % jako nezavislou promennou bere hodnoty jasu v obrazku
        % nejprve ulozime vsechny hodnoty jasu do vektoru
        intensities = reshape(img, siz(1)*siz(2), 1);
        %vybereme pouze unikatni hodnoty, tzn. pokud je tam nejaka hodnota jasu
        %vicekrat, uvazujeme ji pouze jednou
        intensities = unique(intensities);
        oModel = intensities;
        oModel(:,2) = ksdensity(oS, intensities);
        bModel = intensities;
        bModel(:,2) = ksdensity(bS, intensities);
        
        for(i = 1:siz(1))
            for(j = 1:siz(2))
                intens = img(i,j);
                indO = find(oModel(:,1)==intens,1);
                indB = find(bModel(:,1)==intens,1);
                oProb(i,j) = oModel(indO,2);
                bProb(i,j) = bModel(indB,2);
            end
        end
        
    elseif(strcmp(model,'gmm')) % vypocita model objektu a pozadi jako gausovskou smes z oznacenych seedu
        fprintf('gaussian mixture model...')
        oModel = create_model(oS',numGauss);
        bModel = create_model(bS',numGauss);

        oProbV = gaussK(double(imgV)', oModel.priors, oModel.mu, oModel.sigma);
        bProbV = gaussK(double(imgV)', bModel.priors, bModel.mu, bModel.sigma);
        
        oProb = reshape(oProbV, siz(1), siz(2));
        bProb = reshape(bProbV, siz(1), siz(2));
    else
        fprintf('Chyba! Neznamy model pro data term "%s"',model)
        break;
    end
    
    seg0 = oProb < bProb;

    oProbLog = log(oProb+1e-50);
    bProbLog = log(bProb+1e-50);

    oProbLog = oProbLog - min(oProbLog(:));
    bProbLog = bProbLog - min(bProbLog(:));

    Dc = cat(3, oProbLog, bProbLog);
else
    Dc=zeros(size(img));
end

%nastaveni hard constraints = "tvrde" spojeni seedu s objektem nebo pozadim
for(i = 1:size(oSeeds,2))
    Dc(oSeeds(1,i),oSeeds(2,i),1) = hardCons;
    Dc(oSeeds(1,i),oSeeds(2,i),2) = 0;
end

for(i = 1:size(bSeeds,2))
    Dc(bSeeds(1,i),bSeeds(2,i),1) = 0;
    Dc(bSeeds(1,i),bSeeds(2,i),2) = hardCons;
end

% penalizace za nespojitost - podporuje kompaktni objekty
Sc = [ 0, 200; 200,0];
fprintf('hotovo\n')

%% SMOOTH TERM
% pocitani vah n-linek
fprintf('pocitani smooth termu (n-linky)...')
g = fspecial('gauss', [13 13], 2);
dy = fspecial('sobel');
vf = conv2(g, dy, 'valid');

% if(length(siz) == 3)
%     imgray = rgb2gray(img);
% else
%     imgray = img;
% end

Vc = zeros(size(img));
Hc = zeros(size(img));

Vc = abs(imfilter(img, vf, 'symmetric'));
Hc = abs(imfilter(img, vf', 'symmetric'));
fprintf('hotovo\n')

%% GRAPH CUT ALGORITMUS
fprintf('vytvoreni grafu...')
gch = GraphCut('open', lambda * Dc, Sc , exp(-100*Vc), exp(-100*Hc));
fprintf('hotovo\n')
fprintf('expandovani grafu...')
[gch L] = GraphCut('expand', gch);
fprintf('hotovo\n')
fprintf('mazani grafu...')
gch = GraphCut('close', gch);
fprintf('hotovo\n')

%% LABELOVANI VYSLEDKU A VYKRESLENI HRANIC
fprintf('labelovani...')
label = 1;

lb=(L==label) ;
% lb=imdilate(lb,strel('disk',1))-lb ; 
hold on; contour(lb,[1 1],'r', 'Linewidth', 2) ; hold off ;
str1 = strcat('Velikost objektu:');
denzita = [];
for(i = 1:siz(1))
    for(j = 1:siz(2))
        if(lb(i,j))
            denzita(end+1) = img(i,j);
        end
    end
end
str2 = strcat('Stredni jas objektu:');
str = sprintf('%s %d\n%s %f', str1, sum(sum(lb)), str2, mean(denzita));
xPos = get(fig,'Position');
xPos = xPos(3);
ht = uicontrol('Style', 'Text', 'Position', [(xPos/2-90) 20 200 30], 'String', str);
fprintf('hotovo\n')

fprintf('****  KONEC  ****\n')
