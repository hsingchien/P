function loglikelihood = HMMPredict(P, ClassProb, PairProb, actionData, poseData,G)
    N = size(poseData, 1);
    K = size(ClassProb, 2);
    L = size(actionData, 2); % number of actions
    V = size(PairProb, 1);
    loglikelihood = zeros(L,1);
    logEmissionProb = zeros(N,K);
    for npose = 1:N
        O = squeeze(poseData(npose,:,:)); % observation of example npose, 10x3
        prK = EmissionLogLikelihood(O, G, P, K); 
        logEmissionProb(npose,:) = prK;%-logsumexp(prK);
    end
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
     loglikelihood(a) = loglikelihood(a) + logsumexp(PCal.cliqueList(1).val);
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

end

