%% 3-DOF Peg-in-Hole task GMM/GMR
function Teleoperation_3DOF_GMR

clc
clear all
close all

%%
components=20;

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

%% Positions 3-DOF
Position3D_Trial1=Samples(:,1:counter1);
Position3D_Trial1=Position3D_Trial1';
%%
Position3D_Trial2=Samples(:,1:counter1);
Position3D_Trial2=Position3D_Trial2';
%%
Position3D_Trial3=Samples(:,1:counter1);
Position3D_Trial3=Position3D_Trial3';

%% Plot Trials 

length1=size(Position3D_Trial1,1);   
length2=size(Position3D_Trial2,1);   
length3=size(Position3D_Trial3,1);   

Lengths=[length1 length2 length3];  

SIZE=min(Lengths); 

yy11 = spline(linspace(0,1,size(Position3D_Trial1,1)),Position3D_Trial1(1:end,[1 2 3])',linspace(0,1,SIZE));
yy3=yy11';

yy22 = spline(linspace(0,1,size(Position3D_Trial2,1)),Position3D_Trial2(1:end,[1 2 3])',linspace(0,1,SIZE));
yy4=yy22';

yy33 = spline(linspace(0,1,size(Position3D_Trial3,1)),Position3D_Trial3(1:end,[1 2 3])',linspace(0,1,SIZE));
yy5=yy33';

figure;
plot3(yy11(1,:),yy11(2,:),yy11(3,:), 'Color',[0,0,0.9])
grid on;
hold on;

plot3(yy22(1,:),yy22(2,:), yy22(3,:), 'Color',[0,0.9,0])
grid on;
hold on;

plot3(yy33(1,:),yy33(2,:), yy33(3,:), 'Color',[0.9,0,0])
grid on;
hold off;

%% 
PositionData = [[linspace(0,2*pi,SIZE)' yy3];[linspace(0,2*pi,SIZE)' yy4];[linspace(0,2*pi,SIZE)' yy5]];
PositionData = PositionData';

Priors = ones(1,components)/components;
ind = ceil(rand(components,1) * size(PositionData,2));
Mu = PositionData(:,ind);
Sigma = repmat(cov(PositionData')/10,1,1,components);

%% 
[Priors, Mu, Sigma] = EM_Pol(PositionData, 1 , Priors, Mu, Sigma);

%% 
figure;
hold on;
for abc=1:size(Mu,2)
    plot_gaussian_ellipsoid(Mu([2 3 4],abc),Sigma([2 3 4],[2 3 4],abc),1);
end 

%%
Clock=linspace(0,2*pi,20000);
[Traj, Sigma_y] = GMR_Polar(Priors, Mu, Sigma, Clock, 1, [2 3 4],1);

figure;
plot3(Position3D_Trial1(:,1),Position3D_Trial1(:,2),Position3D_Trial1(:,3),'-', 'markerSize', 1, 'color', [.9 0.5 0]);
hold on;
plot3(Position3D_Trial2(:,1),Position3D_Trial2(:,2),Position3D_Trial2(:,3),'-', 'markerSize', 1, 'color', [0 0.9 0]);
plot3(Position3D_Trial3(:,1),Position3D_Trial3(:,2),Position3D_Trial3(:,3),'-', 'markerSize', 1, 'color', [0 0 0.9]);
plot3(Traj(1,:),Traj(2,:),Traj(3,:),'*', 'markerSize', 1, 'color', [.9 0 0]);
hold off;

%% ZMQ (REPLY)

topicfilter2='10002';
port2=5555;

%Socket talk to Server
context2 = zmq.core.ctx_new();
client = zmq.core.socket(context2, 'ZMQ_REP');   % socket for client

% Server talk to client
fprintf('Waiting for client requests...\n');

address2=sprintf('tcp://*:%d',port2);
zmq.core.bind(client, address2);
    

for i=1:length(Traj)
    
    Px=sprintf('%0.4f ',Traj(1,i));
    
    Py=sprintf('%0.4f ',Traj(2,i));
    Pz=sprintf('%0.4f ',Traj(3,i));
   
    data=[Px Py Pz];
    
    message2=char(zmq.core.recv(client));
    
    fprintf('Recieved request from client %s\n',message2);
    fprintf('Sending Position (Px Py Pz) %0.4f % 0.4f % 0.4f to client\n', Traj(1,i), Traj(2,i), Traj(3,i));
    
    zmq.core.send(client, uint8(data));  
    
end

zmq.core.disconnect(cleint, address2);
zmq.core.close(client);
zmq.core.ctx_shutdown(context2);
zmq.core.ctx_term(context2); 

end
