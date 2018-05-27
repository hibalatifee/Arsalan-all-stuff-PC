clc
clear all
close all

alpha=importdata('Dominance.txt');

alpha1_x=alpha(:,1);
alpha1_y=alpha(:,2);
alpha1_z=alpha(:,3);

alpha2_x=1-alpha1_x;
alpha2_y=1-alpha1_y;
alpha2_z=1-alpha1_z;

len=length(alpha1_x);
t=0:0.001:(len-1)/1000;


plot(t,alpha1_x,'b','LineWidth',2);
title('Master1 & 2 alpha (x-axis)');
xlabel('Time (Sec)');
ylabel('Alpha (Dominance) ');

hold on;
plot(t,alpha2_x,'r','LineWidth',2);
hold off;
grid on;
legend('Master1 Alpha in x-asis', 'Master2 Alpha in  x-asis');



figure;
plot(t,alpha1_y,'b','LineWidth',2);
title('Master1 & 2 alpha (y-axis)');
xlabel('Time (Sec)');
ylabel('Alpha (Dominance) ');

hold on;
plot(t,alpha2_y,'r','LineWidth',2);
hold off;
grid on;
legend('Master1 Alpha in y-asis', 'Master2 Alpha in  y-asis');



figure;
plot(t,alpha1_z,'b','LineWidth',2);
title('Master1 & 2 alpha (z-axis)');
xlabel('Time (Sec)');
ylabel('Alpha (Dominance) ');

hold on;
plot(t,alpha2_z,'r','LineWidth',2);
hold off;
grid on;
legend('Master1 Alpha in z-asis', 'Master2 Alpha in  z-asis');

tilefigs();
%% Energy Master1 and Master2

figure;
plot(t,E1_z,'LineWidth',1);
title('Master1 Energy (y-axis)');
xlabel('Time (Sec)');
ylabel('Energy ');
grid on;

figure;
plot(t,E2_z,'LineWidth',1);
title('Master2 Energy (y-axis)');
xlabel('Time (Sec)');
ylabel('Energy ');
grid on;



