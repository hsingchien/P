function accuracy = ClassifyDataset(dataset, labels, P, G)
% returns the accuracy of the model P and graph G on the dataset 
%
% Inputs:
% dataset: N x 10 x 3, N test instances represented by 10 parts
% labels:  N x 2 true class labels for the instances.
%          labels(i,j)=1 if the ith instance belongs to class j 
% P: struct array model parameters (explained in PA description)
% G: graph structure and parameterization (explained in PA description) 
%
% Outputs:
% accuracy: fraction of correctly classified instances (scalar)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

N = size(dataset, 1);
accuracy = 0.0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
right_pred = 0;
for i = 1:N
   O = squeeze(dataset(i,:,:));
   this_pro = ObserveLogLikelihood(O,G,P);
   [bigpro, lab_pred] = max(this_pro);
   if(labels(i,lab_pred)~=0)
       right_pred = right_pred + 1;
   end
end
accuracy = right_pred/N;

fprintf('Accuracy: %.2f\n', accuracy);