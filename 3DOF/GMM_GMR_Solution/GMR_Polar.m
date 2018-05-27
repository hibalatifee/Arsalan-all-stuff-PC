function [y, Sigma_y] = GMR_Polar(Priors, Mu, Sigma, x, in, out,P_Dim)
%

nbData = size(x,2);
nbVar = size(Mu,1);
nbStates = size(Sigma,3);

%% Fast matrix computation (see the commented code for a version involving 
%% one-by-one computation, which is easier to understand).
%%
%% Compute the influence of each GMM component, given input x
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:nbStates
    if(P_Dim~=out)
        Data_Tmp = x(P_Dim,:);
        Data_Tmp = FixPolarRange(Data_Tmp,Mu(P_Dim,i)-pi,Mu(P_Dim,i)+pi);
    end
    Data2(:,:,i)=x;
    if(P_Dim~=out)
        Data2(P_Dim,:,i)=Data_Tmp;  
    end
    Pxi(:,i) = Priors(i).*gaussPDF(Data2(:,:,i), Mu(in,i), Sigma(in,in,i));
end
beta = Pxi./repmat(sum(Pxi,2)+realmin,1,nbStates);
%% Compute expected means y, given input x
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:nbStates
  y_tmp(:,:,j) = repmat(Mu(out,j),1,nbData) + Sigma(out,in,j)*inv(Sigma(in,in,j)) * (Data2(:,:,j)-repmat(Mu(in,j),1,nbData));
end
beta_tmp = reshape(beta,[1 size(beta)]);
if(P_Dim~=out)
    y_tmp2 = repmat(beta_tmp,[length(out) 1 1]) .* y_tmp;
    y = sum(y_tmp2,3);
else
    c_mean = sum(cos(y_tmp).*[repmat(beta_tmp,[length(out) 1 1])],3)./sum([repmat(beta_tmp,[length(out) 1 1])],3);
    s_mean = sum(sin(y_tmp).*[repmat(beta_tmp,[length(out) 1 1])],3)./sum([repmat(beta_tmp,[length(out) 1 1])],3);
    y = atan(s_mean/c_mean);
end

%% Compute expected covariance matrices Sigma_y, given input x
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:nbStates
  Sigma_y_tmp(:,:,1,j) = Sigma(out,out,j) - (Sigma(out,in,j)*inv(Sigma(in,in,j))*Sigma(in,out,j));
end
beta_tmp = reshape(beta,[1 1 size(beta)]);
Sigma_y_tmp2 = repmat(beta_tmp.*beta_tmp, [length(out) length(out) 1 1]) .* repmat(Sigma_y_tmp,[1 1 nbData 1]);
Sigma_y = sum(Sigma_y_tmp2,4);


% %% Slow one-by-one computation (better suited to understand the algorithm) 
% %%
% %% Compute the influence of each GMM component, given input x
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for i=1:nbStates
%   Pxi(:,i) = gaussPDF(x, Mu(in,i), Sigma(in,in,i));
% end
% beta = (Pxi./repmat(sum(Pxi,2)+realmin,1,nbStates))';
% %% Compute expected output distribution, given input x
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% y = zeros(length(out), nbData);
% Sigma_y = zeros(length(out), length(out), nbData);
% for i=1:nbData
%   % Compute expected means y, given input x
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   for j=1:nbStates
%     yj_tmp = Mu(out,j) + Sigma(out,in,j)*inv(Sigma(in,in,j)) * (x(:,i)-Mu(in,j));
%     y(:,i) = y(:,i) + beta(j,i).*yj_tmp;
%   end
%   % Compute expected covariance matrices Sigma_y, given input x
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   for j=1:nbStates
%     Sigmaj_y_tmp = Sigma(out,out,j) - (Sigma(out,in,j)*inv(Sigma(in,in,j))*Sigma(in,out,j));
%     Sigma_y(:,:,i) = Sigma_y(:,:,i) + beta(j,i)^2.* Sigmaj_y_tmp;
%   end
% end
