% File: RecognizeActions.m
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

function [accuracy, predicted_labels] = RecognizeActions(datasetTrain, datasetTest, G, maxIter)

% INPUTS
% datasetTrain: dataset for training models, see PA for details
% datasetTest: dataset for testing models, see PA for details
% G: graph parameterization as explained in PA decription
% maxIter: max number of iterations to run for EM

% OUTPUTS
% accuracy: recognition accuracy, defined as (#correctly classified examples / #total examples)
% predicted_labels: N x 1 vector with the predicted labels for each of the instances in datasetTest, with N being the number of unknown test instances


% Train a model for each action
% Note that all actions share the same graph parameterization and number of max iterations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_label = length(datasetTrain);
models = [];
for i = 1:num_label
    cur_act = datasetTrain(i);
   [P loglikelihood ClassProb PairProb] = EM_HMM(cur_act.actionData, cur_act.poseData,...
       G, cur_act.InitialClassProb, cur_act.InitialPairProb, maxIter);
   this_struct = struct('P', P, 'loglikelihood', loglikelihood, 'ClassProb', ClassProb, 'PairProb', PairProb);
    models = [models; this_struct];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pred_matrix = zeros(size(datasetTest.actionData,2),num_label);
for i = 1:num_label
    cur_model = models(i);
    cur_pred = HMMPredict(cur_model.P,cur_model.ClassProb,cur_model.PairProb,datasetTest.actionData, datasetTest.poseData,G);
    pred_matrix(:,i) = cur_pred;
end
[dummy,predicted_labels] = max(pred_matrix,[],2);
if(isfield(datasetTest, 'labels'))
    accuracy = sum(predicted_labels == datasetTest.labels)/length(datasetTest.labels);
else
   accuracy = 0; 
end
% Classify each of the instances in datasetTrain
% Compute and return the predicted labels and accuracy
% Accuracy is defined as (#correctly classified examples / #total examples)
% Note that all actions share the same graph parameterization



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
