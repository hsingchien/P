% File: EM_HMM.m
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

function [P loglikelihood ClassProb PairProb] = EM_HMM(actionData, poseData, G, InitialClassProb, InitialPairProb, maxIter)

% INPUTS
% actionData: structure holding the actions as described in the PA
% poseData: N x 10 x 3 matrix, where N is number of poses in all actions
% G: graph parameterization as explained in PA description
% InitialClassProb: N x K matrix, initial allocation of the N poses to the K
%   states. InitialClassProb(i,j) is the probability that example i belongs
%   to state j.
%   This is described in more detail in the PA.
% InitialPairProb: V x K^2 matrix, where V is the total number of pose
%   transitions in all HMM action models, and K is the number of states.
%   This is described in more detail in the PA.
% maxIter: max number of iterations to run EM

% OUTPUTS
% P: structure holding the learned parameters as described in the PA
% loglikelihood: #(iterations run) x 1 vector of loglikelihoods stored for
%   each iteration
% ClassProb: N x K matrix of the conditional class probability of the N examples to the
%   K states in the final iteration. ClassProb(i,j) is the probability that
%   example i belongs to state j. This is described in more detail in the PA.
% PairProb: V x K^2 matrix, where V is the total number of pose transitions
%   in all HMM action models, and K is the number of states. This is
%   described in more detail in the PA.

% Initialize variables
N = size(poseData, 1);
K = size(InitialClassProb, 2);
L = size(actionData, 2); % number of actions
V = size(InitialPairProb, 1);

ClassProb = InitialClassProb;
PairProb = InitialPairProb;
loglikelihood = zeros(maxIter, 1);




% EM algorithm
for iter=1:maxIter
  
  % M-STEP to estimate parameters for Gaussians
  % Fill in P.c, the initial state prior probability (NOT the class probability as in PA8 and EM_cluster.m)
  % Fill in P.clg for each body part and each class
  % Make sure to choose the right parameterization based on G(i,1)
  % Hint: This part should be similar to your work from PA8 and EM_cluster.m
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % YOUR CODE HERE
      P.c = zeros(1,K);
    % P.clg.sigma_x = [];
    % P.clg.sigma_y = [];
    % P.clg.sigma_angle = [];
    for i = 1:L % for all actions
       % find the first pose of each action
       first_pose_idx = actionData(i).marg_ind(1);
       first_pose_pro = ClassProb(first_pose_idx,:);
       P.c = P.c + first_pose_pro;
    end
    P.c = P.c/sum(P.c);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  P.clg=repmat(struct('mu_y',[],'sigma_y',[],'mu_x',[],'sigma_x',[],'mu_angle',[],'sigma_angle',[],'theta',[]),1,10);
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
  
  % M-STEP to estimate parameters for transition matrix
  % Fill in P.transMatrix, the transition matrix for states
  % P.transMatrix(i,j) is the probability of transitioning from state i to state j
  P.transMatrix = zeros(K,K);
  
  % Add Dirichlet prior based on size of poseData to avoid 0 probabilities
  P.transMatrix = P.transMatrix + size(PairProb,1) * .05;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % YOUR CODE HERE
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for i = 1:size(PairProb,1)
     this_transition = PairProb(i,:);
     this_trans_mat = reshape(this_transition,[K,K]); % row i col j means P(i->j), the joint prob of being i and trans to j
     P.transMatrix = P.transMatrix + this_trans_mat;
  end
  P.transMatrix = P.transMatrix./sum(P.transMatrix,2);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    
  % E-STEP preparation: compute the emission model factors (emission probabilities) in log space for each 
  % of the poses in all actions = log( P(Pose | State) )
  % Hint: This part should be similar to (but NOT the same as) your code in EM_cluster.m
  
  logEmissionProb = zeros(N,K);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % YOUR CODE HERE
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for npose = 1:N
      O = squeeze(poseData(npose,:,:)); % observation of example npose, 10x3
      prK = EmissionLogLikelihood(O, G, P, K); 
      logEmissionProb(npose,:) = prK;%-logsumexp(prK);
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    
  % E-STEP to compute expected sufficient statistics
  % ClassProb contains the conditional class probabilities for each pose in all actions
  % PairProb contains the expected sufficient statistics for the transition CPDs (pairwise transition probabilities)
  % Also compute log likelihood of dataset for this iteration
  % You should do inference and compute everything in log space, only converting to probability space at the end
  % Hint: You should use the logsumexp() function here to do probability normalization in log space to avoid numerical issues
  
  ClassProb = zeros(N,K);
  PairProb = zeros(V,K^2);
  loglikelihood(iter) = 0;
  InitProb = [];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % YOUR CODE HERE
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for a = 1:L
      cur_action = actionData(a);
      num_poses = length(cur_action.marg_ind);
    %% initial factors P(S1)
    factors = repmat(struct('var',[],'card',[],'val',[]),[1,num_poses]);
    factors(1).var = [1];
    factors(1).card = [K];
    factors(1).val = log(P.c);
    %% emission factors P(Pi|Si)
    for s = 1:num_poses
        factors(s+1).var = [s];
        factors(s+1).card = [K];
        factors(s+1).val = logEmissionProb(cur_action.marg_ind(s),:);
    end
    %% transition factors P(Si+1|Si)
    for s = num_poses+2:2*num_poses
        factors(s).var = [s-num_poses-1, s-num_poses];
        factors(s).card = [K,K];
        factors(s).val = log(reshape(P.transMatrix,[1,K^2]));
    end
     %% inference
     [M, PCal] = ComputeExactMarginalsHMM(factors);
     for i = 1:num_poses
        ClassProb(cur_action.marg_ind(i),:) = M(i).val; 
     end
     for i = 1:num_poses-1
        PairProb(cur_action.pair_ind(i),:) = PCal.cliqueList(i).val; 
     end
     loglikelihood(iter) = loglikelihood(iter) + logsumexp(PCal.cliqueList(1).val);
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  end
  ClassProb = exp(ClassProb - logsumexp(ClassProb));
  PairProb = exp(PairProb - logsumexp(PairProb));
 
  
  % Print out loglikelihood
  disp(sprintf('EM iteration %d: log likelihood: %f', ...
    iter, loglikelihood(iter)));
  if exist('OCTAVE_VERSION')
    fflush(stdout);
  end
  
  % Check for overfitting by decreasing loglikelihood
  if iter > 1
    if loglikelihood(iter) < loglikelihood(iter-1)
      break;
    end
  end
  
end

% Remove iterations if we exited early
loglikelihood = loglikelihood(1:iter);
end
