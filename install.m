% install


% GMM http://www.calinon.ch/sourcecodes.php
% Sylvain Calinon
% This source code is given for free! However, I would be grateful if you refer 
% to the book (or corresponding article) in any academic publication that uses 
% this code or part of it. Here are the corresponding BibTex references: 
%
% @book{Calinon09book,
%   author="S. Calinon",
%   title="Robot Programming by Demonstration: A Probabilistic Approach",
%   publisher="EPFL/CRC Press",
%   year="2009",
%   note="EPFL Press ISBN 978-2-940222-31-5, CRC Press ISBN 978-1-4398-0867-2"
% }
%
% @article{Calinon07,
%   title="On Learning, Representing and Generalizing a Task in a Humanoid Robot",
%   author="S. Calinon and F. Guenter and A. Billard",
%   journal="IEEE Transactions on Systems, Man and Cybernetics, Part B",
%   year="2007",
%   volume="37",
%   number="2",
%   pages="286--298",
% }
mkdir ('extern')
system('wget http://www.calinon.ch/download/GMM-GMR-v2.0.zip')
unzip('GMM-GMR-v2.0.zip','extern')
delete('GMM-GMR-v2.0.zip')



%system('wget http://www.calinon.ch/download/GMM-GMR-v2.0.zip')
unzip('http://home.zcu.cz/~mjirik/liver/gc_veksler.zip','extern')
%delete('GMM-GMR-v2.0.zip')