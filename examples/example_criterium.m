% Demo ukazuje vypocet hodnoty kriteria
addpath('../outsource/gc_veksler')  
img = [10  9  2 ; 8 10  1 ; 10  1  2];
    lambda = 1;
    Dc(:,:,1) = lambda * (img);
    Dc(:,:,2) = lambda * (10 - img);
    Sc = [0 1 ; 1 0];
    labels = [1 1 0 ; 0 0 0 ; 0 0 0];
    [gch] = GraphCut('open', Dc,Sc);
    [gch] = GraphCut('set', gch, labels);
    [gch se de] = GraphCut('energy', gch);
    [gch L] = GraphCut('expand', gch);
    [gch] = GraphCut('close',gch);

    