% File: EM_cluster.m
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

function [P loglikelihood ClassProb] = EM_cluster(poseData, G, InitialClassProb, maxIter)

% INPUTS
% poseData: N x 10 x 3 matrix, where N is number of poses;
%   poseData(i,:,:) yields the 10x3 matrix for pose i.
% G: graph parameterization as explained in PA8
% InitialClassProb: N x K, initial allocation of the N poses to the K
%   classes. InitialClassProb(i,j) is the probability that example i belongs
%   to class j
% maxIter: max number of iterations to run EM

% OUTPUTS
% P: structure holding the learned parameters as described in the PA
% loglikelihood: #(iterations run) x 1 vector of loglikelihoods stored for
%   each iteration
% ClassProb: N x K, conditional class probability of the N examples to the
%   K classes in the final iteration. ClassProb(i,j) is the probability that
%   example i belongs to class j

% Initialize variables
N = size(poseData, 1);
K = size(InitialClassProb, 2);

ClassProb = InitialClassProb;

P.c = [];
P.clg.sigma_x = [];
P.clg.sigma_y = [];
P.clg.sigma_angle = [];
loglikelihood = zeros(maxIter,1);
% EM algorithm
for iter=1:maxIter
  
  % M-STEP to estimate parameters for Gaussians
  %
  % Fill in P.c with the estimates for prior class probabilities
  % Fill in P.clg for each body part and each class
  % Make sure to choose the right parameterization based on G(i,1)
  %
  % Hint: This part should be similar to your work from PA8
  
  P.c = zeros(1,K);
  P.c = sum(ClassProb,1);
  P.c = P.c/sum(P.c);
  single_unit = struct('mu_y',[],'sigma_y',[],'mu_x',[],'sigma_x',[],'mu_angle',[],'sigma_angle',[],'theta',zeros(K,12));
  P.clg = repmat(single_unit, [1,10]);
  for cls = 1:K
      weight_cls = ClassProb(:, cls);
      for node = 1:size(poseData,2) % for nodes
           if(G(node,1) == 0) % root
               data_this_node = squeeze(poseData(:,node,:)); 
               [mu_y, sig_y] = FitG(data_this_node(:,1),weight_cls);
               [mu_x, sig_x] = FitG(data_this_node(:,2),weight_cls);
               [mu_angle, sig_angle] = FitG(data_this_node(:,3),weight_cls);
               P.clg(node).mu_y = [P.clg(node).mu_y, mu_y];
               P.clg(node).mu_x = [P.clg(node).mu_x, mu_x];
               P.clg(node).mu_angle = [P.clg(node).mu_angle, mu_angle];
               P.clg(node).sigma_y = [P.clg(node).sigma_y, sig_y];
               P.clg(node).sigma_x = [P.clg(node).sigma_x, sig_x];
               P.clg(node).sigma_angle = [P.clg(node).sigma_angle, sig_angle];
               P.clg(node).theta = [];
           else
              data_this_node = squeeze(poseData(:,node,:));
              par = G(node, 2);
              data_par = squeeze(poseData(:,par,:));
              [beta_y, sig_y] = FitLG(data_this_node(:,1), data_par, weight_cls);
              [beta_x, sig_x] = FitLG(data_this_node(:,2), data_par, weight_cls);
              [beta_angle, sig_angle] = FitLG(data_this_node(:,3), data_par, weight_cls);
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
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % YOUR CODE HERE
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % E-STEP to re-estimate ClassProb using the new parameters
  %
  % Update ClassProb with the new conditional class probabilities.
  % Recall that ClassProb(i,j) is the probability that example i belongs to
  % class j.
  %
  % You should compute everything in log space, and only convert to
  % probability space at the end.
  %
  % Tip: To make things faster, try to reduce the number of calls to
  % lognormpdf, and inline the function (i.e., copy the lognormpdf code
  % into this file)
  %
  % Hint: You should use the logsumexp() function here to do
  % probability normalization in log space to avoid numerical issues
  
  ClassProb = zeros(N,K);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % YOUR CODE HERE
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 this_loglikelihood = 0;
 for npose = 1:N
    O = squeeze(poseData(npose,:,:)); % observation of example npose, 10x3
    prK = ObserveLogLikelihood(O, G, P, K);
    logsum = logsumexp(prK);
    ClassProb(npose,:) = prK-logsum;
    this_loglikelihood = this_loglikelihood + log(sum(exp(prK)));
 end
 ClassProb = exp(ClassProb);
 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Compute log likelihood of dataset for this iteration
  % Hint: You should use the logsumexp() function here
  loglikelihood(iter) = this_loglikelihood;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % YOUR CODE HERE
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Print out loglikelihood
  disp(sprintf('EM iteration %d: log likelihood: %f', ...
    iter, loglikelihood(iter)));
  if exist('OCTAVE_VERSION')
    fflush(stdout);
  end
  
  % Check for overfitting: when loglikelihood decreases
  if iter > 1
    if loglikelihood(iter) < loglikelihood(iter-1)
      break;
    end
  end
  
end

% Remove iterations if we exited early
loglikelihood = loglikelihood(1:iter);
