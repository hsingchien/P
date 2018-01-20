% Copyright (C) Daphne Koller, Stanford University, 2012

function EUF = CalculateExpectedUtilityFactor( I )

  % Inputs: An influence diagram I with a single decision node and a single utility node.
  %         I.RandomFactors = list of factors for each random variable.  These are CPDs, with
  %              the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional utilities.
  % Return value: A factor over the scope of the decision rule D from I that
  % gives the conditional utility given each assignment for D.var
  %
  % Note - We assume I has a single decision node and utility node.
  X = I.RandomFactors;
  D = I.DecisionFactors;
  U = I.UtilityFactors;
  EUF = struct('var',D.var,'card',D.card,'val',[]);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  D_enum = IndexToAssignment(1:prod(D.card), D.card);
  X_joint = ComputeJointDistribution(X);
  to_be_eliminated = setdiff(X_joint.var, union(D.var, U.var)); % these are irrelevant variables
  X_joint = VariableElimination(X_joint, to_be_eliminated);
  U_par = U.var;
  D_par = D.var;
  U_par_non_D_par = setdiff(U.var, D.var); 
  [C, in, ix] = intersect(U_par_non_D_par, X_joint.var);
  [C, idv, id] = intersect(D.var, X_joint.var);
  U_par_non_D_par_card = X_joint.card(ix);
  X_enum = IndexToAssignment(1:prod(U_par_non_D_par_card),U_par_non_D_par_card);
  u_val = [];
  for i = 1:length(D_enum)
     D_X = D_enum(i,:); 
     evidence1 = cat(2,D.var',D_X');
     obX_joint = ObserveEvidence(X_joint, evidence1,0);
     D_val = D_X(1);
     u = 0;
     for j = 1:length(X_enum)
        evidence2 = cat(2, U_par_non_D_par', X_enum(j,:)');
        evidence = [evidence1;evidence2];
        uassi = zeros(1,length(U.var));
        for uv = 1:length(U.var)
           iduv = find(evidence(:,1)==U.var(uv));
           uassi(uv) = evidence(iduv,2);
        end
        to_be_added = U.val(AssignmentToIndex(uassi, U.card));
        x_assign = zeros(1, length(X_joint.var));
        x_assign(ix) = X_enum(j,:);
        x_assign(id) = D_X(idv);
        xind = AssignmentToIndex(x_assign, X_joint.card);
        u = u+to_be_added * X_joint.val(xind);
     end
     u_val = [u_val, u];
  end
  EUF.val = u_val;
  EUF = SortVar(EUF);
  
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  


  
end  
