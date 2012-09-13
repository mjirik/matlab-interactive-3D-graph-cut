
source = '/home/mjirik/data/queetech/angio/anonymized_dirs/271005008/0010/mdata.mat';
qdir = '/home/mjirik/projects/queetech/';
addpath([qdir 'graphcut/src/matlab/outsource/sliceomatic/sliceomatic']);
addpath([qdir 'graphcut/src/matlab/segment_kmeans']);
im3d = load(source);
im3d = im3d.im3D(:,:,1:end-1);

% urceni popredi a pozadi
[im m]=segment_kmeans(im3d);
imshow(im(:,:,12),[])


% segmentace pomoci graphcut

% vypocet vah
lambda = 37.8;

Sc = [ 0, lambda; lambda,0];


disp ('gc');

Dc1 = abs(im3d - m(1));
Dc2 = abs(im3d - m(2));
Dc = cat(4,Dc1,Dc2);
gch = GraphCut( 'open', Dc, Sc );
[gch L] = GraphCut( 'expand', gch );
gch = GraphCut( 'close', gch );
