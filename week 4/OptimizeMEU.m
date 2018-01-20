% Copyright (C) Daphne Koller, Stanford University, 2012

function [MEU OptimalDecisionRule] = OptimizeMEU( I )

  % Inputs: An influence diagram I with a single decision node and a single utility node.
  %         I.RandomFactors = list of factors for each random variable.  These are CPDs, with
  %              the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional utilities.
  % Return value: the maximum expected utility of I and an optimal decision rule 
  % (represented again as a factor) that yields that expected utility.
  
  % We assume I has a single decision node.
  % You may assume that there is a unique optimal decision.
  D = I.DecisionFactors(1);
  dvars = D.var;
  dvar = D.var(1);
  D = SortVar(D);
  OptimalDecisionRule = D;
  OptimalDecisionRule.val = zeros(1,prod(OptimalDecisionRule.card));
  euf = CalculateExpectedUtilityFactor(I);
  if(length(D.var) > 1) % D has parents
      dind = find(D.var == dvar);
      MEU = 0;
      assigns = IndexToAssignment(1:prod([D.card(1:dind-1),D.card(dind+1:end)]),[D.card(1:dind-1),D.card(dind+1:end)]);
      for i = 1:length(assigns)
         Xs = assigns(i,:);
         us = [];
         ids = [];
         for j = 1:D.card(dind)
            id = [Xs(1:dind-1), j, Xs(dind:end)];
            did = AssignmentToIndex(id, euf.card);
            us = [us, euf.val(did)];
            ids = [ids, did];
         end
         [mu, md] = max(us);
         MEU = MEU+mu;
         OptimalDecisionRule.val(ids(md)) = 1;
      end
  else % D does not have parents
      [mu, md] = max(euf.val);
      OptimalDecisionRule.val(md) = 1;
      MEU = mu;
  end
%   OptimalDecisionRule = Reorder(OptimalDecisionRule,dvars);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % YOUR CODE HERE...
  % 
  % Some other information that might be useful for some implementations
  % (note that there are multiple ways to implement this):
  % 1.  It is probably easiest to think of two cases - D has parents and D 
  %     has no parents.
  % 2.  You may find the Matlab/Octave function setdiff useful.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    


end
