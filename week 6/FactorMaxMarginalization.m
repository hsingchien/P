% FactorMaxMarginalization Max-marginalizes a factor 
% by taking the max over a given set variables.
% 
%   B = FactorMaxMarginalization(A,V) computes the factor with the variables
%   in V maxed out. The factor data structure has the following fields:
%       .var    Vector of variables in the factor, e.g. [1 2 3]
%       .card   Vector of cardinalities corresponding to .var, e.g. [2 2 2]
%       .val    Value table of size prod(.card)
%
%   B.var will be A.var minus V.
%   For each assignment in B, its value is the maximum value in A 
%   of all assignments in A consistent with that assignment in B.
%
%   The resultant factor should have at least one variable remaining or this
%   function will throw an error.
%
%   This is exactly the same as FactorMarginalization, 
%   but with the sum replaced by a max.
% 
%   See also FactorMarginalization.m, IndexToAssignment.m, and AssignmentToIndex.m
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function B = FactorMaxMarginalization(A, V)

% Check for empty factor or variable list
if (isempty(A.var) || isempty(V)), B = A; return; end;

% Construct the output factor over A.var \ V (the variables in A.var that are not in V)
% and mapping between variables in A and B
[B.var, mapB] = setdiff(A.var, V);
% mapB is the index of B var in A var
% Check for empty resultant factor
if isempty(B.var)
  error('Error: Resultant factor has empty scope');
end;

% initialization
% you should set them to the correct values in your code
B.card = A.card(mapB);
B.val = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
% Correctly set up and populate the factor values of B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Aassigns = IndexToAssignment(1:prod(A.card), A.card);
Bassigns = IndexToAssignment(1:prod(B.card),B.card);
for i = 1:size(Bassigns, 1)
   ass = Bassigns(i,:);
   pool = [];
   for j = 1:size(Aassigns, 1)
       if(Aassigns(j,mapB) == ass)
           pool = [pool,A.val(j)];
       end
   end
   B.val = [B.val, max(pool)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
