function [Priors, Mu, Sigma, Pix] = EM_Pol(Data,P_Dim, Priors0, Mu0, Sigma0)

%% Criterion to stop the EM iterative update
loglik_threshold = 1e-10;

%% Initialization of the parameters
[nbVar, nbData] = size(Data);
nbStates = size(Sigma0,3);
loglik_old = -realmax;
nbStep = 0;

Mu = Mu0;
Sigma = Sigma0;
Priors = Priors0;

%% EM fast matrix computation (see the commented code for a version 
%% involving one-by-one computation, which is easier to understand)
for MaxSteps=1:100
  %% E-step %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for i=1:nbStates
    %Compute probability p(x|i)
    Data_Tmp = Data(P_Dim,:);
    Data_Tmp = FixPolarRange(Data_Tmp,Mu(P_Dim,i)-pi,Mu(P_Dim,i)+pi);
    Data2(:,:,i)=Data;
    Data2(P_Dim,:,i)=Data_Tmp;
%     figure;
%     plot(Data2(1,:),Data2(2,:),'*','color',[0.5 0 0.5]);
    Pxi(:,i) = gaussPDF(Data2(:,:,i), Mu(:,i), Sigma(:,:,i));
  end 
  %Compute posterior probability p(i|x)
  Pix_tmp = repmat(Priors,[nbData 1]).*Pxi;
  Pix = Pix_tmp ./ repmat(sum(Pix_tmp,2),[1 nbStates]);
  %Compute cumulated posterior probability
  E = sum(Pix);
  Priors_Old = Priors;
  Mu_Old = Mu;
  Sigma_Old = Sigma;
  %% M-step %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for i=1:nbStates
    %Update the priors
    Priors(i) = E(i) / nbData;
    %Update the centers
    Mu(:,i) = Data2(:,:,i)*Pix(:,i) / E(i);
    Data_Tmp = Data(P_Dim,:);
    Data_Tmp = FixPolarRange(Data_Tmp,Mu(P_Dim,i)-pi,Mu(P_Dim,i)+pi);
    Data2(:,:,i)=Data;
    Data2(P_Dim,:,i)=Data_Tmp;
    %Update the covariance matrices
    Data_tmp1 = Data2(:,:,i) - repmat(Mu(:,i),1,nbData);
    Sigma(:,:,i) = (repmat(Pix(:,i)',nbVar, 1) .* Data_tmp1*Data_tmp1') / E(i);
    %% Add a tiny variance to avoid numerical instability
%     Sigma(:,:,i) = Sigma(:,:,i) + 1E-6.*diag(ones(nbVar,1));
    
    [V D] = eig(Sigma(:,:,i));
    D=diag(D);
    D(D<1E-2) = 1E-2;
    D=diag(D);
    Sigma(:,:,i) = V*D*V';
%     
  end
  Mu(P_Dim,:) = FixPolarRange(Mu(P_Dim,:),0,2*pi);
  
  %% Stopping criterion %%%%%%%%%%%%%%%%%%%%
%   for i=1:nbStates
%     %Compute the new probability p(x|i)
%     Pxi(:,i) = gaussPDF(Data, Mu(:,i), Sigma(:,:,i));
%   end
%   %Compute the log likelihood
%   F = Pxi*Priors';
%   F(find(F<realmin)) = realmin;
%   loglik = mean(log(F));
loglik = sum((Priors_Old-Priors).^2) + sum(sum((Mu_Old-Mu).^2)) + sum(sum(sum((Sigma_Old-Sigma).^2)));

  %Stop the process depending on the increase of the log likelihood 
  if abs((loglik/loglik_old)-1) < loglik_threshold
    break;
  end
  loglik_old = loglik;
  nbStep = nbStep+1;
end

% %% EM slow one-by-one computation (better suited to understand the
% %% algorithm) 
% while 1
%   %% E-step %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   for i=1:nbStates
%     %Compute probability p(x|i)
%     Pxi(:,i) = gaussPDF(Data, Mu(:,i), Sigma(:,:,i));
%   end
%   %Compute posterior probability p(i|x)
%   for j=1:nbData
%     Pix(j,:) = (Priors.*Pxi(j,:))./(sum(Priors.*Pxi(j,:))+realmin);
%   end
%   %Compute cumulated posterior probability
%   E = sum(Pix);
%   %% M-step %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   for i=1:nbStates
%     %Update the priors
%     Priors(i) = E(i) / nbData;
%     %Update the centers
%     Mu(:,i) = Data*Pix(:,i) / E(i);
%     %Update the covariance matrices 
%     covtmp = zeros(nbVar,nbVar);
%     for j=1:nbData
%       covtmp = covtmp + (Data(:,j)-Mu(:,i))*(Data(:,j)-Mu(:,i))'.*Pix(j,i);
%     end
%     Sigma(:,:,i) = covtmp / E(i);
%   end
%   %% Stopping criterion %%%%%%%%%%%%%%%%%%%%
%   for i=1:nbStates
%     %Compute the new probability p(x|i)
%     Pxi(:,i) = gaussPDF(Data, Mu(:,i), Sigma(:,:,i));
%   end
%   %Compute the log likelihood
%   F = Pxi*Priors';
%   F(find(F<realmin)) = realmin;
%   loglik = mean(log(F));
%   %Stop the process depending on the increase of the log likelihood 
%   if abs((loglik/loglik_old)-1) < loglik_threshold
%     break;
%   end
%   loglik_old = loglik;
%   nbStep = nbStep+1;
% end

%% Add a tiny variance to avoid numerical instability
% for i=1:nbStates
%   Sigma(:,:,i) = Sigma(:,:,i) + 1E-4.*diag(ones(nbVar,1));
% end
end

