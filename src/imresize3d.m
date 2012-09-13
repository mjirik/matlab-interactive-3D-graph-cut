% Funkce provadi zmenu velikosti obrazu
%
% imresize3d(im, scale, ...)
% im: 3D image
% scale: meritko, muze byt take pouzito pole, to pak znamena pozadovanou
%     velikost
% 'zscale': meritko v ose z
% 'method': metoda, viz imresize
%
% Example:
%   imres = imresize3d(im,0.5,'zscale',2,'method','nearest');
%
% imres = imresize3d(im,[255 255 30]);
function im = imresize3d(im, scale, varargin)

p = inputParser; 
p.addParamValue('zscale',false);
% p.addParamValue('newsize',false);
p.addParamValue('method',false);

 p.parse(varargin{:});
params = p.Results;


if ndims(im) ~= 3
    error('Data musi byt 3D');
end

if params.zscale == false
    params.zscale = scale;
end

resparams = {};
if params.method ~= false
    resparams = {params.method};
end

imsize = size(im);

if numel(scale) == 1
    % je to skutecne meritko
    newsize = round(imsize * scale);

    % pokud je z jine, tak se prepocte
    newsize(3) = round(imsize(3)*params.zscale);
elseif numel(scale) == 3
    % jsou to nove rozmery
    newsize = scale;
else
    error ('chyba v druhem parametru');
end






im = shiftdim(im,2);
im = imresize(im,[newsize(3), imsize(1)], resparams{:});
im = shiftdim(im,1);
im = imresize(im, newsize(1:2), resparams{:});

% im1 = shiftdim(im,2);
% im2 = imresize(im1,[zsiz, imsize(1)], resparams{:});
% im2 = shiftdim(im2,1);
% im3 = imresize(im2,xyscale,resparams{:});
