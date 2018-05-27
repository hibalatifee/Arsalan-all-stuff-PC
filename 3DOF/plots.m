%%
clc
clear all
close all

%% Experiment 1 (Peg-in-hole task )
addpath('E:\ARSLAN ALI\LFD_Experiments\requestedData\Experiment1\Subject1');
load('Position3D_experiment1_subject1.mat');

%% Experiment 2 (Peg-in-hole task Starting from different holes)
addpath('E:\ARSLAN ALI\LFD_Experiments\requestedData\Experiment2\Subject1');
load('Trial1.mat')


%% Plot Trials (Experiment#1)

figure;
plot3(Position3D_experiment1_subject1(1,:),Position3D_experiment1_subject1(2,:),Position3D_experiment1_subject1(3,:), 'Color',[0,0,0.9])
grid on;

%% Plot Trials (Experiment#2)

figure;
plot3(Position3D_Subject1_firstHole(1,1),Position3D_Subject1_firstHole(2,1),Position3D_Subject1_firstHole(3,1),'x','Linewidth',2, 'Color',[0,0,0.9])
hold on;
plot3(Position3D_Subject1_firstHole(1,:),Position3D_Subject1_firstHole(2,:),Position3D_Subject1_firstHole(3,:), 'Color',[0,0,0.9])
grid on;

figure;
plot3(Position3D_Subject1_secondHole(1,1),Position3D_Subject1_secondHole(2,1),Position3D_Subject1_secondHole(3,1),'x','Linewidth',2, 'Color',[0,0.9,0])
grid on;
hold on;
plot3(Position3D_Subject1_secondHole(1,:),Position3D_Subject1_secondHole(2,:),Position3D_Subject1_secondHole(3,:), 'Color',[0,0,0.9])
grid on;

figure;
plot3(Position3D_Subject1_thirdHole(1,1),Position3D_Subject1_thirdHole(2,1),Position3D_Subject1_thirdHole(3,1),'x','Linewidth',2, 'Color',[0.9,0,0])
grid on;
hold on;
plot3(Position3D_Subject1_thirdHole(1,:),Position3D_Subject1_thirdHole(2,:),Position3D_Subject1_thirdHole(3,:),'Color',[0,0,0.9])
grid on;

figure;
plot3(Position3D_Subject1_fourthHole(1,1),Position3D_Subject1_fourthHole(2,1),Position3D_Subject1_fourthHole(3,1),'x','Linewidth',2, 'Color',[0.9,0,0.9])
grid on;
hold on;
plot3(Position3D_Subject1_fourthHole(1,:),Position3D_Subject1_fourthHole(2,:),Position3D_Subject1_fourthHole(3,:),'Color',[0,0,0.9])
grid on;
