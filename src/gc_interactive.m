% Funkce provede interaktivni segmentaci pomoci GC.
%% Funkce provede interaktivni segmentaci pomoci GC.
%
%  segmantation = gc_interactive(img)
%
% Po spusteni nabehne graficke rozhrani. Stisknuti tlacitka
% (leveho/praveho) se zahaji oznacovani seedu (objektu/pozadi). Dalsim
% stiskem je oznaceni ukonceno a je mozno zadavat znova. Ukonceni
% oznacovani je provadeno klavesou ENTER. Krome vstupnich dat lze
% nastavovat jeste dalsi parametry.
%
%  [segmantation,seeds] = gc_interactive(img, 'nghb',4) ;
%
% 'lambda': nastavuje hodnotu N-linek na pevnou hodnotu, vychozi je 30.
% 'nghb': volba okoli. Vychozi je 8-okoli, tedy 8
% 'scale': zmenseni pred zpracovanim, vhodne pro velke obrazy
% 'rescale': navrat do puvodni velikosti (true,false)
%  segmantation = gc_interactive(img)
%
% Zname chyby:
% Pri oznacovani nesmi uzivatel oznacit oblast mimo obraz, dojde pak k
% padu.

% 'sparseSmothness': zohledneni nespojitosti v obraze
function [segmentation, seeds] = gc_interactive(img, varargin)
p = inputParser;
 
       
       p.addParamValue('lambda',30); % sila vazby se sousednimi pixely
       p.addParamValue('nghb',8); % velikost okoli
       % pocet gausovek
       p.addParamValue('ng',2); % pocet gaussovek v modelu
       p.addParamValue('K',200); % na kolik jsou nastavovany seedy
       p.addParamValue('almostzero',1e-50); % nevyznamna konstanta male hodnoty
       p.addParamValue('scale',1); % mozno pro zpracovani zmensit,
       % ma smysl zejmena pro 3d
       p.addParamValue('rescale',true); % zvesteni zpet do puvodniho meritka
       p.addParamValue('outputCheck', true); % bude se zobrazovat vysledek a bude-li uzivatel nespokojen, muze upravovat
       p.addParamValue('iterative', true);
       p.addParamValue('seeds', false); % Umoznuje zadat seedy uz na vsupu, pak je metoda neinteraktivni
       p.addParamValue('viewerParams',{}); % dalsi para
       %p.addParamValue('sparseSmothness', false); % zohledneni nespojitosti v obraze
       %p.addParamValue('color',false); % dalsi para
       p.parse(varargin{:});
params = p.Results;

if (ndims(img) == 3) && (size(img,3) ~= 3)
    % pokud je 3d a není to rgb
    process3d = true;
    ndm = 3;
elseif (ndims(img) == 2) || (ndims(img) == 3)
    process3d = false;
    ndm = 2;
else
    error('Dimenze vstupnich dat musi byt 2 nebo 3');
end

%% Cesty k externim zdroju
%clear, clc, close

% Cesta ke GMM - nástroj pro modelování gaussovských směsí
%     http://lasa.epfl.ch/sourcecode/index.php
%addpath('../extern/GMM-GMR-v2.0/');
% addpath('../extern/gmm/');


% Cesta k matlab wrapperu C funkce graph-cut
% Implementace gc v jazyce C
%     http://www.csd.uwo.ca/~olga/code.html
% Matlab wrapper
%     http://vision.ucla.edu/~brian/gcmex.html
%addpath('../extern/gc_veksler/');
%addpath('../gauss_tools/');
%addpath('../gui_tools/');

% prohlizec
addpath('../extern/m3DSeedEditor/');


%addpath('../src/');

%% Zmena velikosti
sizeIn = size(img);

%img = imresize(img, params.scale);
if process3d
    %     pokud ma obraz 3 dimenze a neni barevny
    img = imresize3d(img, params.scale);
    if ~islogical(params.seeds)
        params.seeds = imresize3d(params.seeds, params.scale);
    end
else
    img = imresize(img, params.scale);
    if ~islogical(params.seeds)
        params.seeds = imresize(params.seeds, params.scale);
    end
end


    %% Oznaceni seedu
    % spusteni oznacovaci funkce
    % parametry jsou cislo fgury a velikost okoli
    % zacina se kreslit kliknutim,      konci se dalsim kliknutim
    % oSeeds a bSeeds jsou seznamy bodu oznacenych pravym a levym mysitkem
    
    if islogical(params.seeds)
        if process3d
            seeds = int8(m3DSeedEditor((img), params.viewerParams{:}));
        else
            img = im2double(img);
            fig=gcf;
            close(fig);
            fig = figure(fig);
            imshow(img);
            nghb = params.nghb;
            
            [oSeeds, bSeeds oSeedsIm, bSeedsIm] = markSeeds(fig, nghb);
            seeds = oSeedsIm - bSeedsIm;
        end
    else
        % seedy jsou zadany na vstupu
        seeds=params.seeds;
    end
    
staleIterujeme = true;

while staleIterujeme
    %% Tvorba modelu
    
    %pokud je obrazek barevny, tohle bere jen r-kanal
    if process3d == false && (size(img,3) == 3)
        imgr = img(:,:,1);
        imgg = img(:,:,2);
        imgb = img(:,:,3);
        oSr = double(imgr(seeds == 1));
        bSr = double(imgr(seeds ==-1));
        oSg = double(imgg(seeds == 1));
        bSg = double(imgg(seeds ==-1));
        oSb = double(imgb(seeds == 1));
        bSb = double(imgb(seeds ==-1));
        oS = [oSr oSg oSb];
        bS = [bSr bSg bSb];

    else
        oS = double(img(seeds == 1));
        bS = double(img(seeds ==-1));

    end
    % oS = double(selectPoints(img, oSeeds(1,:), oSeeds(2,:)));
    % bS = double(selectPoints(img, bSeeds(1,:), bSeeds(2,:)));
    
    % tohle jen ukaze stredni hodnotu z vybranych oblasti
    
    oModel = create_model(oS',params.ng);
    bModel = create_model(bS',params.ng);
    
    siz = size(img);
    
    % % osetreni RGB
    % if(length(siz) == 3)
    %     imgV = reshape(img, siz(1)*siz(2), siz(3));
    % else
    %     imgV = reshape(img, siz(1)*siz(2), 1);
    % end
    
    imgV = reshape(img, prod(siz(1:ndm)),[]);
    %imgV = reshape(img, siz(1)*siz(2),[]);
    
    oProbV = gaussK(double(imgV)', oModel.priors, oModel.mu, oModel.sigma);
    bProbV = gaussK(double(imgV)', bModel.priors, bModel.mu, bModel.sigma);
    
    oProb = reshape (oProbV, siz(1:ndm));
    bProb = reshape (bProbV, siz(1:ndm));
    
    %seg0 = oProb > bProb;
    clear ('oProbV', 'bProbV','imgV','oS','bS');
    
    %% Vypocet vah N-linku
    % vypocet vah
    % lambda = 37.8;
    lambda = params.lambda;
    Sc = [ 0, lambda; lambda,0];
    
    smCost = {};
    % if process3d && params.sparseSmothness
    %     % tohle bohuzel nefunguje. GC pocita dost dlouho
    %     smCost = {img};
    % end
    
    
    %% Vypocet vah T-linku
    oProbLog = -log(oProb + params.almostzero);
    bProbLog = -log(bProb + params.almostzero);
    clear ('oProb', 'bProb');
    % oProbLog = log(oProb + params.almostzero);
    % bProbLog = log(bProb + params.almostzero);
    %
    % % nejmensi minimum, aby to bylo kladne, ale odecitalo se porad stejne
    % minoffset  = min(min(oProbLog(:)), min(bProbLog(:)));
    % oProbLog = oProbLog - minoffset;
    % bProbLog = bProbLog - minoffset;
    
    % pevne spojeni s s a t
    % nastavime nuly tam kde jsou pixely oznaceny
    K = params.K;
    oProbLog = oProbLog .* (seeds == 0);
    bProbLog = bProbLog .* (seeds == 0);
    
    objW = oProbLog + K.*(seeds == -1);
    bckW = bProbLog + K.*(seeds == 1);
    
    clear ('oProbLog', 'bProbLog');
    
    Dc = cat(ndm+1, bckW,objW );
    clear ('bckW', 'objW');
    % oProbLog = oProbLog .* (1 - oSeedsIm) .* (1 - bSeedsIm);
    % bProbLog = bProbLog .* (1 - bSeedsIm) .* (1 - oSeedsIm);
    % objW = oProbLog + K.*oSeedsIm;
    % bckW = bProbLog + K.*bSeedsIm;
    %
    % Dc = cat(3, objW,bckW );
    
    %% Vypocet rezu grafem
    
    
    gch = GraphCut( 'open', uint8(Dc), Sc, smCost{:} );
    [gch segmentation] = GraphCut( 'expand', gch );%smCost{:});
    gch = GraphCut( 'close', gch );
    
    % pro 3d je nutno prerovnat
    segmentation = uint8(reshape(segmentation,siz(1:ndm)));
    
    %% kontrola vysledku
    staleIterujeme = false;
    if params.outputCheck
        if process3d
            seedsNew = int8(m3DSeedEditor((img), 'labels', segmentation, 'seeds', seeds, params.viewerParams{:}));
            if all(seeds == seedsNew)
                staleIterujeme = false;
            else
                %
                staleIterujeme = true;
            end
            seeds = seedsNew;
            clear seedsNew
        else
%             seedsNew = int8(viewerGUI2((img), 'labels', segmentation, 'seeds', seeds, params.viewerParams{:}));
%             if all(seeds == seedsNew)
%                 staleIterujeme = false;
%             else
%                 %
%                 staleIterujeme = true;
%             end
%             seeds = seedsNew;
%             clear seedsNew
staleIterujeme = false;
% tohle funguje
%             img = im2double(img);
%             fig=gcf;
%             close(fig);
%             fig = figure(fig);
%             imshow(img);
%             nghb = params.nghb;
%            
%             [oSeeds, bSeeds oSeedsIm, bSeedsIm] = markSeeds(fig, nghb);
%             seeds = oSeedsIm - bSeedsIm;
% -----------------
        end
    end
    
    
end % iterace

%% Zvetseni zpet
if params.rescale
%     segmentation = imresize(segmentation,1/params.scale,'nearest');
%     seeds = imresize(seeds,1/params.scale,'nearest');
if process3d
    %     pokud ma obraz 3 dimenze a neni barevny
    %img = imresize3d(img, params.scale);
    segmentation = imresize3d(segmentation,sizeIn,'method','nearest');
    seeds = imresize3d(seeds, sizeIn,'method','nearest');
else
    img = imresize(img, sizeIn(1:2));
end
    
    
    
    
%     sizeOut= size(segmentation);
%    
%     if sizeIn ~= sizeOut
%         warning('Zaokrouhlovaci chyba pri vypoctu poctu rezu');
%         seeds = seeds(1:sizeIn(1), 1:sizeIn(2),1:sizeIn(3));
%         segmentation = segmentation(1:sizeIn(1), 1:sizeIn(2),1:sizeIn(3));
%     end
end
