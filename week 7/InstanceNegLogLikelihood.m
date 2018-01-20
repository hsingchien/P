% function [nll, grad] = InstanceNegLogLikelihood(X, y, theta, modelParams)
% returns the negative log-likelihood and its gradient, given a CRF with parameters theta,
% on data (X, y). 
%
% Inputs:
% X            Data.                           (numCharacters x numImageFeatures matrix)
%              X(:,1) is all ones, i.e., it encodes the intercept/bias term.
% y            Data labels.                    (numCharacters x 1 vector)
% theta        CRF weights/parameters.         (numParams x 1 vector)
%              These are shared among the various singleton / pairwise features.
% modelParams  Struct with three fields:
%   .numHiddenStates     in our case, set to 26 (26 possible characters)
%   .numObservedStates   in our case, set to 2  (each pixel is either on or off)
%   .lambda              the regularization parameter lambda
%
% Outputs:
% nll          Negative log-likelihood of the data.    (scalar)
% grad         Gradient of nll with respect to theta   (numParams x 1 vector)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

function [nll, grad] = InstanceNegLogLikelihood(X, y, theta, modelParams)

    % featureSet is a struct with two fields:
    %    .numParams - the number of parameters in the CRF (this is not numImageFeatures
    %                 nor numFeatures, because of parameter sharing)
    %    .features  - an array comprising the features in the CRF.
    %
    % Each feature is a binary indicator variable, represented by a struct 
    % with three fields:
    %    .var          - a vector containing the variables in the scope of this feature
    %    .assignment   - the assignment that this indicator variable corresponds to
    %    .paramIdx     - the index in theta that this feature corresponds to
    %
    % For example, if we have:
    %   
    %   feature = struct('var', [2 3], 'assignment', [5 6], 'paramIdx', 8);
    %
    % then feature is an indicator function over X_2 and X_3, which takes on a value of 1
    % if X_2 = 5 and X_3 = 6 (which would be 'e' and 'f'), and 0 otherwise. 
    % Its contribution to the log-likelihood would be theta(8) if it's 1, and 0 otherwise.
    %
    % If you're interested in the implementation details of CRFs, 
    % feel free to read through GenerateAllFeatures.m and the functions it calls!
    % For the purposes of this assignment, though, you don't
    % have to understand how this code works. (It's complicated.)
    
    featureSet = GenerateAllFeatures(X, modelParams);

    % Use the featureSet to calculate nll and grad.
    % This is the main part of the assignment, and it is very tricky - be careful!
    % You might want to code up your own numerical gradient checker to make sure
    % your answers are correct.
    %
    % Hint: you can use CliqueTreeCalibrate to calculate logZ effectively. 
    %       We have halfway-modified CliqueTreeCalibrate; complete our implementation 
    %       if you want to use it to compute logZ.
    
    nll = 0;
    grad = zeros(size(theta));
    factors = [];
    %%%
    % Your code here:
    %% create clique tree
    % create factor list
    for feat = featureSet.features
        fvar = feat.var;
        fassign = feat.assignment;
        fpara = feat.paramIdx;
        already_exist = false;
        for i = 1:length(factors)
           if(isequal(sort(fvar), sort(factors(i).var)))
               already_exist = true;
               break;
           end
           already_exist = false;
        end
        if(already_exist)
            this_fac = factors(i);
            idx = AssignmentToIndex(fassign, factors(i).card);
            this_fac.val(idx) = this_fac.val(idx) + theta(fpara);
            factors(i) = this_fac;
        else
            nulfac = struct('var', fvar, 'card', ...
                ones(1,length(fvar))*modelParams.numHiddenStates, 'val',zeros(1, modelParams.numHiddenStates^length(fvar)));
            idx = AssignmentToIndex(fassign, ones(1,length(fvar))*modelParams.numHiddenStates);
            nulfac.val(idx) = theta(fpara);
            factors = [factors, nulfac];
        end
    end
    for i = 1:length(factors)
       factors(i).val = exp(factors(i).val); 
    end
    % create clique tree
    clique_tree = CreateCliqueTree(factors);
    [P, logZ] = CliqueTreeCalibrate(clique_tree, 0);
    
    %% weighted feature counts and data feature count
    wfc = zeros(1, featureSet.numParams);
    dfc = zeros(1, featureSet.numParams);
    for feat = featureSet.features
        yassign = y(sort(feat.var));
        [a, b] = sort(feat.var);
        fassign = feat.assignment(b);
        if(isequal(yassign, fassign))
           wfc(feat.paramIdx) = wfc(feat.paramIdx) + theta(feat.paramIdx);
           dfc(feat.paramIdx) = dfc(feat.paramIdx) + 1;
        end        
    end
    
   %% the regularization cost and regularization gradient term
   lambda = modelParams.lambda;
   regcost = lambda/2 *sum(theta.^2);
   reggrad = lambda * theta;
   
   %% the model expected feature counts
   mfc = zeros(1, featureSet.numParams);
   for j = 1:length(P.cliqueList)
       P.cliqueList(j).val = P.cliqueList(j).val/sum(P.cliqueList(j).val);
   end
   for feat = featureSet.features
      fvar = feat.var;
      fassign = feat.assignment;
      fpara = feat.paramIdx;
      % find the clique that contains vars of feature
      % for caliberated clique, to compute the marginal, simply find a
      % clique that contains the targeted variable, marginalize out the
      % unused variables. the result does not depend on which clique you
      % use.
      for j = 1:length(P.cliqueList)
          this_clique = P.cliqueList(j);
          if(isequal(sort(intersect(this_clique.var, fvar)),sort(fvar)))
             break; 
          end
      end
      unused_var = setdiff(P.cliqueList(j).var, fvar);
      FactorY = FactorMarginalization(P.cliqueList(j), unused_var);
      py = FactorY.val(AssignmentToIndex(feat.assignment, FactorY.card));
      mfc(fpara) = mfc(fpara) + py;
   end
  
   %% last step, compute the output
   
   nll = logZ - sum(wfc) + regcost;
   grad = mfc - dfc + reggrad;
   
end
