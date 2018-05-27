function GMM_GMR_Solution

clear all;
close all;

addpath('R:\Matlab_C++_Development\Matlab_development\LFD_RESEARCH\Data_Sets\Case 01');
%%
components = 20;

load('Trial1 Data.mat');
load('Trial2 Data.mat');
load('Trial3 Data.mat');
load('Trial4 Data.mat');
load('Trial5 Data.mat');


%%
yy = spline(linspace(0,1,16983),Master1_Position_Trial1(1:16983,[1 2 3])',linspace(0,1,13000));
yy1=yy';

yy = spline(linspace(0,1,13323),Master1_Position_Trial2(1:13323,[1 2 3])',linspace(0,1,13000));
yy2=yy';

yy = spline(linspace(0,1,13449),Master1_Position_Trial3(1:13449,[1 2 3])',linspace(0,1,13000));
yy3=yy';

yy = spline(linspace(0,1,13002),Master1_Position_Trial4(1:13002,[1 2 3])',linspace(0,1,13000));
yy4=yy';

yy = spline(linspace(0,1,12351),Master1_Position_Trial5(1:12351,[1 2 3])',linspace(0,1,13000));
yy5=yy';



% plot3(Master1_Position_Trial3(1:13284,1),Master1_Position_Trial3(1:13284,2),Master1_Position_Trial3(1:13284,3));
% hold on;
% plot3(yy3(:,1),yy3(:,2),yy3(:,3));

% plot3(Master1_Position_Trial2(1:13000,1),Master1_Position_Trial2(1:13000,2),Master1_Position_Trial2(1:13000,3));
% plot3(Master1_Position_Trial3(1:13000,1),Master1_Position_Trial3(1:13000,2),Master1_Position_Trial3(1:13000,3));
% plot3(Master1_Position_Trial4(1:12560,1),Master1_Position_Trial4(1:12560,2),Master1_Position_Trial4(1:12560,3));
% plot3(Master1_Position_Trial5(1:13400,1),Master1_Position_Trial5(1:13400,2),Master1_Position_Trial5(1:13400,3));

% figure;
% hold on;
% for i=1:10000
% %     plot3(Master1_Position_Trial1(i,1),Master1_Position_Trial1(i,2),Master1_Position_Trial1(i,3),'or');
%     plot3(Master1_Position_Trial2(i,1),Master1_Position_Trial2(i,2),Master1_Position_Trial2(i,3),'oy');
%     plot3(Master1_Position_Trial3(i,1),Master1_Position_Trial3(i,2),Master1_Position_Trial3(i,3),'om');
%     plot3(Master1_Position_Trial4(i,1),Master1_Position_Trial4(i,2),Master1_Position_Trial4(i,3),'oc');
%     plot3(Master1_Position_Trial5(i,1),Master1_Position_Trial5(i,2),Master1_Position_Trial5(i,3),'og');   
%     drawnow;
% end


% PositionData = [Master1_Position_Trial1;Master1_Position_Trial2;Master1_Position_Trial3;Master1_Position_Trial4;Master1_Position_Trial5];
% PositionData = [[cumsum(0.1*ones(length(Master1_Position_Trial2),1)) Master1_Position_Trial2];[cumsum(0.1*ones(length(Master1_Position_Trial3),1)) Master1_Position_Trial3];[cumsum(0.1*ones(length(Master1_Position_Trial4),1)) Master1_Position_Trial4];[cumsum(0.1*ones(length(Master1_Position_Trial5),1)) Master1_Position_Trial5]];
% PositionData = [[linspace(0,2*pi,13000)' yy2];[linspace(0,2*pi,13000)' yy3];[linspace(0,2*pi,13000)' yy4];[linspace(0,2*pi,13000)' yy5]];
PositionData = [[linspace(0,2*pi,13000)' yy3];[linspace(0,2*pi,13000)' yy4];[linspace(0,2*pi,13000)' yy5]];


%%
Diff_Data = [PositionData(2:end,:)-PositionData(1:end-1,:)];

% Position_Diff_Data = [PositionData(1:end-1,:) Diff_Data]';
Position_Diff_Data = [PositionData]';

Priors = ones(1,components)/components;
ind = ceil(rand(components,1) * size(Position_Diff_Data,2));
Mu = Position_Diff_Data(:,ind);
Sigma = repmat(cov(Position_Diff_Data')/10,1,1,components);

%%
% [Priors, Mu, Sigma] = EM_boundingCovTele(Position_Diff_Data, Priors, Mu, Sigma);
[Priors, Mu, Sigma] = EM_Pol(Position_Diff_Data, 1 , Priors, Mu, Sigma);

figure;
hold on;
for abc=1:size(Mu,2)
    plot_gaussian_ellipsoid(Mu([2 3 4],abc),Sigma([2 3 4],[2 3 4],abc),1);
end 


% figure
% plot(Master1_Position_Trial1(:,1));
% hold on;
% plot(Master1_Position_Trial2(:,2));
% plot(Master1_Position_Trial3(:,3));
% plot(Master1_Position_Trial4(:,4));
% plot(Master1_Position_Trial5(:,5));

% in=[1 2 3];
% out=[4 5 6];
in=[1];
out=[2 3 4];

% Start_Pos = Master1_Position_Trial2(1,:)';
Clock = 0.0;
% Traj=[Start_Pos];


% plot3(yy1(1,1),yy1(1,2),yy1(1,3),'*r','MarkerSize',20);
% plot3(yy2(1,1),yy2(1,2),yy2(1,3),'*r','MarkerSize',20);
% plot3(yy3(1,1),yy3(1,2),yy3(1,3),'*r','MarkerSize',20);
% plot3(yy4(1,1),yy4(1,2),yy4(1,3),'*r','MarkerSize',20);
% plot3(yy5(1,1),yy5(1,2),yy5(1,3),'*r','MarkerSize',20);
% [Clock, Sigma_y] = GMR_Polar_max(Priors, Mu, Sigma, Start_Point', [2 3 4], 1,1);

Traj=[];
Traj_Length = 20000;


for j=1:Traj_Length
    
    [y, Sigma_y] = GMR_Polar(Priors, Mu, Sigma, Clock, in, out,1);
    Start_Pos = y;
    Traj = [Traj Start_Pos];
    Clock = Clock + (2*pi/12000);
end

Clock
figure;
plot3(Traj(1,:),Traj(2,:),Traj(3,:));
hold on;
% plot3(Start_Point(1),Start_Point(2),Start_Point(3),'*r','MarkerSize',20);
plot3(Master1_Position_Trial2(:,1),Master1_Position_Trial2(:,2),Master1_Position_Trial2(:,3));
plot3(Master1_Position_Trial3(:,1),Master1_Position_Trial3(:,2),Master1_Position_Trial3(:,3));
plot3(Master1_Position_Trial4(:,1),Master1_Position_Trial4(:,2),Master1_Position_Trial4(:,3));
plot3(Master1_Position_Trial5(:,1),Master1_Position_Trial5(:,2),Master1_Position_Trial5(:,3));

end