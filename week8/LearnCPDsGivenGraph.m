function [P loglikelihood] = LearnCPDsGivenGraph(dataset, G, labels)
%
% Inputs:
% dataset: N x 10 x 3, N poses represented by 10 parts in (y, x, alpha)
% G: graph parameterization as explained in PA description
% labels: N x 2 true class labels for the examples. labels(i,j)=1 if the 
%         the ith example belongs to class j and 0 elsewhere        
%
% Outputs:
% P: struct array parameters (explained in PA description)
% loglikelihood: log-likelihood of the data (scalar)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

N = size(dataset, 1);
K = size(labels,2);

loglikelihood = 0;
P.c = zeros(1,K);
single_unit = struct('mu_y',[],'sigma_y',[],'mu_x',[],'sigma_x',[],'mu_angle',[],'sigma_angle',[],'theta',zeros(K,12));
P.clg = repmat(single_unit, [1,10]);

% estimate parameters
% fill in P.c, MLE for class probabilities
% fill in P.clg for each body part and each class
% choose the right parameterization based on G(i,1)
% compute the likelihood - you may want to use ComputeLogLikelihood.m
% you just implemented.
%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE

% These are dummy lines added so that submit.m will run even if you 
% have not started coding. Please delete them.
if(size(G,3) == 1)
    G = cat(3,G,G);
end
for cls = 1:K
    P.c(cls) = sum(labels(:,cls))/size(labels,1);
    data_this_cls = dataset(find(labels(:,cls)==1),:,:); % data instances with this class label
    for node = 1:size(dataset,2) % for nodes
       if(G(node,1,cls) == 0) % root
           data_this_node = squeeze(data_this_cls(:,node,:));
           [mu_y, sig_y] = FitGaussianParameters(data_this_node(:,1));
           [mu_x, sig_x] = FitGaussianParameters(data_this_node(:,2));
           [mu_angle, sig_angle] = FitGaussianParameters(data_this_node(:,3));
           P.clg(node).mu_y = [P.clg(node).mu_y, mu_y];
           P.clg(node).mu_x = [P.clg(node).mu_x, mu_x];
           P.clg(node).mu_angle = [P.clg(node).mu_angle, mu_angle];
           P.clg(node).sigma_y = [P.clg(node).sigma_y, sig_y];
           P.clg(node).sigma_x = [P.clg(node).sigma_x, sig_x];
           P.clg(node).sigma_angle = [P.clg(node).sigma_angle, sig_angle];
           P.clg(node).theta = [];
       else
          data_this_node = squeeze(data_this_cls(:,node,:));
          par = G(node, 2,cls);
          data_par = squeeze(data_this_cls(:,par,:));
          [beta_y, sig_y] = FitLinearGaussianParameters(data_this_node(:,1), data_par);
          [beta_x, sig_x] = FitLinearGaussianParameters(data_this_node(:,2), data_par);
          [beta_angle, sig_angle] = FitLinearGaussianParameters(data_this_node(:,3), data_par);
          P.clg(node).sigma_y = [P.clg(node).sigma_y, sig_y];
          P.clg(node).sigma_x = [P.clg(node).sigma_x, sig_x];
          P.clg(node).sigma_angle = [P.clg(node).sigma_angle, sig_angle];
          P.clg(node).theta(cls,1) = beta_y(4);
          P.clg(node).theta(cls,2:4) = beta_y(1:3);
          P.clg(node).theta(cls,5) = beta_x(4);
          P.clg(node).theta(cls,6:8) = beta_x(1:3);
          P.clg(node).theta(cls,9) = beta_angle(4);
          P.clg(node).theta(cls,10:12) = beta_angle(1:3);
       end  
    end
end
loglikelihood = ComputeLogLikelihood(P,G,dataset);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('log likelihood: %f\n', loglikelihood);

