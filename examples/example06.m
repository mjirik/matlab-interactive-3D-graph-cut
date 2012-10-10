%% Ukazka uziti jednoduche interaktivni segmentace pomoci GC
% Po spusteni nabehne graficke rozhrani. Stisknuti tlacitka
% (leveho/praveho) se zahaji oznacovani seedu (objektu/pozadi). Dalsim
% stiskem je oznaceni ukonceno a je mozno zadavat znova. Ukonceni
% oznacovani je provadeno klavesou ENTER. Krome vstupnich dat lze
% nastavovat jeste dalsi parametry.
addpath('../outsource/gc_veksler/');
addpath('../gui_tools');

img = imread('cameraman.tif');
% img = imread('football.jpg');
% img = imread('http://147.228.47.85/snapshot.jpg');
segmentation = gc_interactive(img, 'nghb', 4);

%% Vykresleni vysledku
% nove vykresleni obrazku - je tak videtkolik se toho nacetlo

% jako co je nas obrazek
label = 1;

lb=(segmentation==label) ;
lb=imdilate(lb,strel('disk',1))-lb ; 
hold on; contour(lb,[1 1],'g') ; hold off ;
