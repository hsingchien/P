%GETNEXTCLIQUES Find a pair of cliques ready for message passing
%   [i, j] = GETNEXTCLIQUES(P, messages) finds ready cliques in a given
%   clique tree, P, and a matrix of current messages. Returns indices i and j
%   such that clique i is ready to transmit a message to clique j.
%
%   We are doing clique tree message passing, so
%   do not return (i,j) if clique i has already passed a message to clique j.
%
%	 messages is a n x n matrix of passed messages, where messages(i,j)
% 	 represents the message going from clique i to clique j. 
%   This matrix is initialized in CliqueTreeCalibrate as such:
%      MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);
%
%   If more than one message is ready to be transmitted, return 
%   the pair (i,j) that is numerically smallest. If you use an outer
%   for loop over i and an inner for loop over j, breaking when you find a 
%   ready pair of cliques, you will get the right answer.
%
%   If no such cliques exist, returns i = j = 0.
%
%   See also CLIQUETREECALIBRATE
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function [i, j] = GetNextCliques(P, messages)

% initialization
% you should set them to the correct values in your code
i = 0;
j = 0;

G = P.edges; % edge matrix
N = size(messages, 1); % number of nodes
mes_monitor = zeros(size(G));
for i = 1:N
    for j = 1:N
        if(~isempty(messages(i,j).var))
            mes_monitor(i,j) = 1;
        end
    end
end
cr_state = G-mes_monitor; % marks all the non message edges
rec_state = sum(cr_state,1);
se_state = sum(cr_state,2);
roots = find(rec_state==0); % rec = 0 means the node has received all inputs

% case1
if(length(roots) == 0)
    passed = find(se_state==0); % se = 0 means the node has send all outputs
    ready_send = setdiff(find(rec_state==1),passed);
    for s = 1:length(ready_send)
       this_node = ready_send(s);
       target = find(cr_state(:,this_node)==1);
       if(cr_state(this_node,target)==1)
           i = this_node;
           j = target;
           break;
       end
    end
elseif(length(roots)==N)
    i=0;
    j=0;
else
% case2
    passed = find(se_state==0);
    ready_send = setdiff(roots,passed);
    i = min(ready_send);
    j = find(cr_state(i,:)==1,1);
end
end
    

% the next stop should be in the following 2 cases:
% 1, if no roots, then find the smallest one with all but target message
% received
% 2, if roots are formed, find the smallest roots outgoing passage
% roots only starts to form when the upward passing is finished




