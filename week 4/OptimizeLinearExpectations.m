% Copyright (C) Daphne Koller, Stanford University, 2012

function [MEU OptimalDecisionRule] = OptimizeLinearExpectations( I )
  % Inputs: An influence diagram I with a single decision node and one or more utility nodes.
  %         I.RandomFactors = list of factors for each random variable.  These are CPDs, with
  %              the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional utilities.
  % Return value: the maximum expected utility of I and an optimal decision rule 
  % (represented again as a factor) that yields that expected utility.
  % You may assume that there is a unique optimal decision.
  %
  % This is similar to OptimizeMEU except that we will have to account for
  % multiple utility factors.  We will do this by calculating the expected
  % utility factors and combining them, then optimizing with respect to that
  % combined expected utility factor.  
  MEU = [];
  OptimalDecisionRule = [];
  D = I.DecisionFactors(1);
  dvars = D.var;
  dvar = D.var(1);
  D = SortVar(D);
  OptimalDecisionRule = D;
  OptimalDecisionRule.val = zeros(1,prod(OptimalDecisionRule.card));
  euf = [];
  for ui = 1:length(I.UtilityFactors)
      temp_I = I;
      temp_I.UtilityFactors = I.UtilityFactors(ui);
      euf = [euf,CalculateExpectedUtilityFactor(temp_I)];
  end
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
            did = AssignmentToIndex(id, euf(1).card);
            us_temp = 0;
            for sks = 1:length(euf)
               us_temp = us_temp + euf(sks).val(did);
            end
            us = [us, us_temp];
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
  

end
