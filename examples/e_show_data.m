% Oprava chyby v DICOM
%
%   qdicomanon  - Opravuje soubory ve v�ech podardes���ch, v�etn�
%   aktu�ln�ho adres��e
%
%   qdicomanon('adresar') - Opravuje data ve v�ech podadres���ch
%   zadan�ho adres��e, ale ukl�d� do aktu�ln�ho. V praxi se moc nevyu�ije
%
%   qdicomanon('adresar1', 'adresar2') - Opravuje data v podadres���ch
%   adres��e adresar1 a ukl�d� je se stejnou hirearchi� do adres��e
%   adresar2
%
%   qdicomanon('adresar1','adresar2', X ) - stejn� jako p�edchoz�. parametr
%   X dovoluje nastavit p�episov�n� soubor�. 0 - existuj�c� soubory se
%   p�esko�� . 1 - zpracuje v�echny soubory
%
%   Queetech 2009 - (author : Petr Neduchal, Miroslav Jiřík)


% kontrola, jestli se nechyst�me ��st z c�lov�ho adres��e. P�i absenci
% podm�nky se m�e zacyklovat cel� skript
source = '/home/mjirik/data/queetech/angio/anonymized_dirs/271005008/0008/';
% checkDir = [ './' , newDir ];
% if strcmpi(source , checkDir) == 1
%    return
% end
qdir = '/home/mjirik/projects/queetech/';
addpath([qdir 'graphcut/src/matlab/outsource/sliceomatic/sliceomatic']);
% nastaven� zdrojov�ho adres��e
d = dir(source);

im = [];
imshow(im,[]);
im3D = [];
for p = 1:numel(d)
    if d(p).isdir == 0 
        
        % Zji�t�n� d�lky n�zvu aktu�ln�ho souboru
        dLength = length(d(p).name);
        % Zji�t�n� p��pony aktu�ln�ho souboru
        postName = d(p).name((dLength-2):dLength);        
        if 1   %strcmpi(postName ,'dcm')
            
                        
            try 
                disp(['Soubor : ', source ,'/' , d(p).name ]);                
                % Na�ten� informac� z DICOM souboru do prom�nn� info
                info = dicominfo(sprintf('%s/%s', source, d(p).name));
                im = dicomread(sprintf('%s/%s', source, d(p).name));
                imshow(im,[])
                drawnow;
                im3D = cat(3,im,im3D);
                if strcmpi(postName ,'dcm')
                  d(p).name = [d(p).name '.dcm'];
                end
% cilem je pouzivat i info z  dicom, je nutno odstranit chybu.                
%                 dicomwrite(im, sprintf('%s/%s', newDir ,d(p).name), info);
%                 dicomwrite(im, sprintf('%s/%s', newDir ,d(p).name));
            catch exception
                disp(fprintf('Error: Soubor %s/%s nen� ve spr�vn�m form�tu',  source, d(p).name));  
            end
        end
    else 
        disp(['Soubor : ', source ,'/' , d(p).name ]);           
        if d(p).name(length(d(p).name)) ~= '.'
            % Zano�en� programu do podadres��e
            %qdicomanon([source , '/' , d(p).name], [newDir , '/' , d(p).name], overwrite); 
        end
    end
end
pixelSize=[];
pixelSize = info.PixelSpacing;
pixelSize(3) = info.SliceThickness*.10;
imsiz = size(im3D);
save([source '/' 'mdata.mat'], 'im3D');
% in
sliceomatic (double(im3D),1:imsiz(1)*pixelSize(1), 1:imsiz(2)*pixelSize(2),1:imsiz(3)*pixelSize(3))