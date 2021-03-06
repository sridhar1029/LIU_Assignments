function [Wout,Vout, trainingError, testError ] = trainMultiLayer(Xtraining,Dtraining,Xtest,Dtest, W0, V0,numIterations, learningRate )
%TRAINMULTILAYER Trains the network (Learning)
%   Inputs:
%               X* - Trainin/test features (matrix)
%               D* - Training/test desired output of net (matrix)
%               V0 - Weights of the output neurons (matrix)
%               W0 - Weights of the output neurons (matrix)
%               numIterations - Number of learning setps (scalar)
%               learningRate - The learningrate (scalar)
%
%   Output:
%               Wout - Weights after training (matrix)
%               Vout - Weights after training (matrix)
%               trainingError - The training error for each iteration
%                               (vector)
%               testError - The test error for each iteration
%                               (vector)

% Initiate variables
trainingError = nan(numIterations+1,1);
testError = nan(numIterations+1,1);
numTraining = size(Xtraining,2);
numTest = size(Xtest,2);
numClasses = size(Dtraining,1) - 1;
Wout = W0;
Vout = V0;

%%
% Calculate initial error
Ytraining = runMultiLayer(Xtraining, W0, V0);
Ytest = runMultiLayer(Xtest, W0, V0);
trainingError(1) = sum(sum((Ytraining - Dtraining).^2))/(numTraining*numClasses);
testError(1) = sum(sum((Ytest - Dtest).^2))/(numTest*numClasses);

%%
fprintf("Starting")

for n = 1:numIterations 
    %fprintf("%i\n",n)
    for j=1:numTraining
        xtrain = Xtraining(:,j);
        Wout_old = Wout;
        Vout_old = Vout;
        
        V_wo = Vout(:,[2:end]);
        Y = runMultiLayer(xtrain, Wout, Vout);
        S = Wout*xtrain;
        U=[ones(1,size(xtrain,2));tanh(S)];
    
        grad_v = (2*(Y-Dtraining(:,j))*(U)')/numClasses; %Calculate the gradient with respect to weight for the output layer
        grad_w = (2*(V_wo)'*(Y-Dtraining(:,j)).*(1-(tanh(S).^2))*(xtrain)')/numClasses; %..and for the hidden layer weights.

        Wout = Wout - learningRate * grad_w; %Take the learning step.
        Vout = Vout - learningRate * grad_v; %Take the learning step.
    end
        
    Ytraining = runMultiLayer(Xtraining, Wout, Vout);
        
    Ytest = runMultiLayer(Xtest, Wout, Vout);

    trainingError(1+n) = sum(sum((Ytraining - Dtraining).^2))/(numTraining*numClasses);
    testError(1+n) = sum(sum((Ytest - Dtest).^2))/(numTest*numClasses);
%     if(testError(n)-testError(n+1) < -0.0001)
%         Wout = Wout_old;
%         Vout = Vout_old;
%         trainingError(1+n)= NaN;
%         testError(1+n) = NaN;
%         break
%      end 
end
trainingError = trainingError(1:n);
testError = testError(1:n);   %Send back  only speciefied number of train and test error
end
