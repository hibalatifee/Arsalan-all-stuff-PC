clc
clear all
close all

%% ZMQ Subscriber

topicfilter1='10001';
port1=5551;

Samples=zeros(3,100000);
Button=zeros (1,100000);

counter1=0;

% Socket to talk to server
context1 = zmq.core.ctx_new();
subscriber = zmq.core.socket(context1, 'ZMQ_SUB');  

% Subscribe to the server
fprintf('Collecting updates from Phantom...\n');

address1 = sprintf('tcp://localhost:%d', port1);
zmq.core.connect(subscriber, address1);

zmq.core.setsockopt(subscriber, 'ZMQ_SUBSCRIBE', topicfilter1);


while (1)
    
%     try

        message1=zmq.core.recv(subscriber);
        
        parts=strsplit(char(message1));
        
        [topic,flag,px,py,pz]=parts{:};

        if (flag=='2')     
            break;
        end
        
        counter1=counter1+1;
        
        topic=str2double(topic);
        flag=str2double(flag);
        Px=str2double(px);
        Py=str2double(py);
        Pz=str2double(pz);
        
        fprintf('Recieved Positions (Px, py, pz) %0.4f %0.4f %0.4f with Flag %d on Topic %d\n', Px, Py, Pz,flag,topic);  
        
        Samples(:,counter1)=[Px Py Pz];
        Button(:,counter1)=flag;
        
%         clf;
%         plot(Px, Py);
%         drawnow;
%     catch e
%         
%         tf2=strcmp(e.identifier, 'zmq:core:recv:EAGAIN');
%         
%         if (tf2==1)
%             
%             fprintf('No message avaliable.\n');
%             break;
%             
%         else
%             rethrow(e);
%         end
%   
%     end

end
   
zmq.core.disconnect(subscriber, address1);
zmq.core.close(subscriber);
zmq.core.ctx_shutdown(context1);
zmq.core.ctx_term(context1); 


%% Experiment 1 (4 subjects,3 trials each)

%% Subject 1
Position3D_experiment1_subject1=Samples(:,1:counter1);


%% Experiment 2 (4 trials each starting from 4 different locations, 4 subjects)
%% Subject 1
experiment1_subject3_trial1=Samples(:,1:counter1);

%%
experiment1_subject3_trial2=Samples(:,1:counter1);

%%
experiment1_subject3_trial3=Samples(:,1:counter1);

%%
experiment1_subject3_trial4=Samples(:,1:counter1);
%%
Position3D_experiment2_fourthHole=Samples(:,1:counter1);


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
