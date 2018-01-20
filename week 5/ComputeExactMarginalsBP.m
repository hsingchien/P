%COMPUTEEXACTMARGINALSBP Runs exact inference and returns the marginals
%over all the variables (if isMax == 0) or the max-marginals (if isMax == 1). 
%
%   M = COMPUTEEXACTMARGINALSBP(F, E, isMax) takes a list of factors F,
%   evidence E, and a flag isMax, runs exact inference and returns the
%   final marginals for the variables in the network. If isMax is 1, then
%   it runs exact MAP inference, otherwise exact inference (sum-prod).
%   It returns an array of size equal to the number of variables in the 
%   network where M(i) represents the ith variable and M(i).val represents 
%   the marginals of the ith variable. 
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function M = ComputeExactMarginalsBP(F, E, isMax)

% initialization
% you should set it to the correct value in your code
M = [];
P = CreateCliqueTree(F,E);
P = CliqueTreeCalibrate(P, isMax);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Implement Exact and MAP Inference.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
var_list = {P.cliqueList.var};
vars = unique([P.cliqueList.var]); % a list of all variables
for i = 1:length(vars)
   target_var = vars(i);
   for j = 1:length(var_list)
      if(~isempty(find(var_list{j}==target_var)))
         break;
      end
   end
   to_be_margi = setdiff(var_list{j}, target_var);
    if(isMax == 0)
       exact_margi = FactorMarginalization(P.cliqueList(j),to_be_margi);
       exact_margi.val = exact_margi.val/sum(exact_margi.val);
    else
       exact_margi = FactorMaxMarginalization(P.cliqueList(j),to_be_margi);
    end
   M = [M, exact_margi];
end



end
