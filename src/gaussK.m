% Funkce vraci vazeny soucet hodnot hustotnich funkci, ktere jsou dany
% stredni hodnotou Mu a kovariancni matici Sigma. Vahy jednotlivych
% gaussovych funkci jsou uvedeny v Priors. 
%
% Data(k,n): Vstupni vektor o velikosti KxN, kde K je rozmer priznakoveho
%   prostoru a N je pocet bodu k zarazeni
%   Data = [bod1_priznakA bod2_priznakA bod3_priznakA
%           bod1_priznakB bod2_priznakB bod3_priznakB]
% Priors: Pravdepodobnost, ze bod prislusi k te ktere gaussovce
%   Priors = [p_gauss1 p_gauss2 p_gauss3]
    
function [probAll, probEach] = gaussK(Data, Priors, Mu, Sigma)
% prob = zeros([size(Data,2), 1]);
probAll = [];
probEach = zeros([size(Data,2), size(Priors,2)]);

data_max_size = 500000;
% data_max_size = 1000;

for j = 1:data_max_size:size(Data,2)
  Hindex = min(j + data_max_size - 1,size(Data,2));
  DataI = Data(:,j:Hindex);
  probI = zeros([size(DataI,2), 1]);
  for i = 1:size(Priors,2)
    probK = gaussPDF(DataI, Mu(:,i), Sigma(:,:,i));
    probI = probI + Priors(i) * probK;
    probEach(j:Hindex,i) = Priors(i) * probK ;
  end
  probAll(j:Hindex,:) = probI;
end