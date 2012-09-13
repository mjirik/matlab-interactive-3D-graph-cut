% featuresV = 
%      [ point1_featureA point1_featureB point1_featureC
%        point2_featureA point2_featureB point2_featureC
%                :                :              :
%        pointN_featureA pointN_featureB pointN_featureC ]
function model = create_model(featuresV, k )
%featuresV = featuresV';
if nargin < 2
    k = 1;
end

if ((nargin < 1 ) | (nargin > 2))
    error('chybny pocet parametru');
end

if k == 1
  Priors = [1]; %kxk (1x1)
  Mu = mean(featuresV,2);%Nxk (24x1)
  Sigma = cov(featuresV');%NxN (24x24)
else
  % vice gaussovek
  [Priors, Mu, Sigma] = EM_init_kmeans(featuresV, k);
  [Priors, Mu, Sigma] = EM(featuresV, Priors, Mu, Sigma);
end
model.priors = Priors;
model.mu = Mu;
model.sigma = Sigma;
model.k = k;