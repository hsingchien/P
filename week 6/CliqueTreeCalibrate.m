%CLIQUETREECALIBRATE Performs sum-product or max-product algorithm for 
%clique tree calibration.

%   P = CLIQUETREECALIBRATE(P, isMax) calibrates a given clique tree, P 
%   according to the value of isMax flag. If isMax is 1, it uses max-sum
%   message passing, otherwise uses sum-product. This function 
%   returns the clique tree where the .val for each clique in .cliqueList
%   is set to the final calibrated potentials.
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function P = CliqueTreeCalibrate(P, isMax)


% Number of cliques in the tree.
N = length(P.cliqueList);

% Setting up the messages that will be passed.
% MESSAGES(i,j) represents the message going from clique i to clique j. 
MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% We have split the coding part for this function in two chunks with
% specific comments. This will make implementation much easier.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[i,j] = GetNextCliques(P,MESSAGES);
if(isMax == 0)

    while(i ~= 0 & j ~= 0)
        scope_i = P.cliqueList(i).var;
        scope_j = P.cliqueList(j).var;
        marg = setdiff(scope_i, scope_j);
        mess = P.cliqueList(i);
        incoming_edges = find(P.edges(:,i) == 1);
        incoming_edges(incoming_edges == j)=[];
    for n = 1:length(incoming_edges)
        mess = FactorProduct(mess, MESSAGES(incoming_edges(n),i));
    end
        mess = FactorMarginalization(mess, marg);
        mess.val = mess.val/sum(mess.val);
        MESSAGES(i,j) = mess;
        [i,j] = GetNextCliques(P, MESSAGES);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% YOUR CODE HERE
% While there are ready cliques to pass messages between, keep passing
% messages. Use GetNextCliques to find cliques to pass messages between.
% Once you have clique i that is ready to send message to clique
% j, compute the message and put it in MESSAGES(i,j).
% Remember that you only need an upward pass and a downward pass.
%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Now the clique tree has been calibrated. 
% Compute the final potentials for the cliques and place them in P.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:N
        for j = 1:N
            P.cliqueList(i) = FactorProduct(P.cliqueList(i), MESSAGES(j,i));
        end
    end
else
    % log factors
    for ff = 1:length(P.cliqueList)
       P.cliqueList(ff).val = log(P.cliqueList(ff).val); 
    end
    while(i ~= 0 & j ~= 0)
            scope_i = P.cliqueList(i).var;
            scope_j = P.cliqueList(j).var;
            marg = setdiff(scope_i, scope_j);
            mess = P.cliqueList(i);
            incoming_edges = find(P.edges(:,i) == 1);
            incoming_edges(incoming_edges == j)=[];
        for n = 1:length(incoming_edges)
            mess = FactorSum(mess, MESSAGES(incoming_edges(n),i));
        end
            mess = FactorMaxMarginalization(mess, marg);
            MESSAGES(i,j) = mess;
            [i,j] = GetNextCliques(P, MESSAGES);
    end
    for i = 1:N
        for j = 1:N
            P.cliqueList(i) = FactorSum(P.cliqueList(i), MESSAGES(j,i));
        end
    end
end




return
