function UR5_Draw(data)
w = 0.4;
pos = [0.35;-w/2;0.15];

%% Robot Model

% Flange to TCP
toolpos = [0.06, 0, 0.06*sqrt(3)];
j=30;
tcp = [[cosd(j),0,sind(j);0,1,0;-sind(j),0,cosd(j)],toolpos';0,0,0,1];

% Base
base = eye(4);

% Model
[KinePara,DispPara,PreSetting] = model_UR5(tcp,base);

%% Setup Simulation

% Construct the Robot
myRob = SimpleRobotRJ(KinePara,DispPara);

% Joint Limit (Optional)
% If not specify, will be +-pi
myRob.jrange = PreSetting.jrange;

% Set Home Position (Optional)
myRob.home = PreSetting.Home;

% Base Frame and Tool Frame Size (Optional)
% If not specify, will not show frames
myRob.frame0Size = 0.12;
myRob.frametSize = 0.03;

myRob.RobName = PreSetting.Name;
myRob.tcptrace = false;
myRob.tracealpha = 1;
myRob.tracewidth = 3;
myRob.ShowRobot(myRob.home);
axis([ -0.2000    0.8600   -0.2800    0.4500   -0.0300    0.6200])
view(20,30)


%%


n = size(data,2);
data = [data*w+pos(1:2);ones(1,n)*pos(3)];

plot3(data(1,:),data(2,:),data(3,:),':','color',[0 0.4470 0.7410],'LineWidth',1); hold on

intpos = myRob.home;
intpos(4) = -120/180*pi;
pause(0.5)
myRob.MoveAbsJ(intpos,'AngleStep',[1,1,1,1,1,1]/180*pi);
orit = myRob.cpose(1:3,1:3);
pose1 = [orit,data(:,1);0,0,0,1];

myRob.RRMove(pose1);

pause(0.2)
myRob.tcptrace = true;
myRob.keeptrace = true;
gotonext = true;

for i = 1:n

%%
    if isnan(data(1,i)) && gotonext == true

        indnext = find(~isnan(data(1,i+1:end)),1)+i;
        myRob.RRMove(pose1,'errlim',[1/1000,1/180*pi]);
        myRob.hidetrace = true;
        myRob.Offs([0,0,0.05],'errlim',[5/1000,1/180*pi]);
        
        nextpos = data(:,indnext);
        pose2 = [orit,nextpos+[0;0;0.05];0,0,0,1];
        myRob.RRMove(pose2,'errlim',[5/1000,1/180*pi]);
        myRob.RRMove(nextpos,'errlim',[2/1000,1/180*pi]);
        myRob.hidetrace = false;
        gotonext = false;

    elseif ~isnan(data(1,i))
        gotonext = true;
        pose1 = [orit,data(:,i);0,0,0,1];
        if i == n
            myRob.RRMove(pose1);
        else
            myRob.RRMove(pose1,'maxloop',30,'warnmaxloop',false,...
                'k',0.5,'errlim',[3/1000,1/180*pi]);
        end
    end


end
myRob.hidetrace = true;
myRob.GoHome;

%%
myRob.Jog;
end
