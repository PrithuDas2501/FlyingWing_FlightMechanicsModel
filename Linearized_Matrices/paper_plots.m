clc; clear;
h2 = load("h2_design.mat");
hinf = load('hinf_design.mat');
%%
d2r = pi/180;
A = h2.Aclp;
B = [h2.Bd h2.Bu];
B = [B; zeros(3,4)];
%Scale = [1/(5*d2r) 0; 0 1/10]; %%%%% DOUBT REGARDING THIS! -- This is correct. We want to plot normalized z.
Scale = eye(2);
Cz = Scale*[1 0 -1 0; 0 1 0 0];
C = [Cz zeros(2,3);zeros(3,4) eye(3)];
sys_h2 = ss(A,B,C,[]);

Tend = 1000;
T = 0:0.1:Tend;
N = length(T);
dalpha = (rand(N,1)-0.5)*2 + sin(0.05*T)' + sin(0.01*T)' + sin(1*T)';
dalpha_bar = dalpha/(trapz(T,dalpha.^2))^0.5;
Wd = 10;

Wa = diag(h2.kappa.^-0.5);
%Wa = 0*eye(3);
wa = (rand(N,3)-0.5)*2;


wa_bar = wa/(trapz(T,(wa.^2)*[1;1;1])^0.5);
u = [Wd*dalpha_bar wa_bar*Wa]; %%%%%% Should 0.01 be there for dalpha? Yes
X0 = [0;0;0;0;0;0;0];
sol_h2 = lsim(sys_h2,u,T,X0);

A = hinf.Aclp;
B = [hinf.Bd hinf.Bu];
B = [B; zeros(3,4)];
Cz = Scale*[1 0 -1 0; 0 1 0 0];
C = [Cz zeros(2,3);zeros(3,4) eye(3)];
sys_hinf = ss(A,B,C,[]);

% T = 0:0.1:Tend;
% N = length(T);
% dalpha = (rand(N,1)-0.5)*2 + 10*sin(0.1*T)';
% dalpha_bar = dalpha/(trapz(T,dalpha.^2))^0.5;
Wa = diag(hinf.kappa.^-0.5);
%Wa = 0*eye(3);
%wa = (rand(N,3)-0.5)*2;
wa_bar = wa/(trapz(T,(wa.^2)*[1;1;1])^0.5);
u = [Wd*dalpha_bar wa_bar*Wa]; %%%%%% Shohuld 0.01 be there for dalpha? Yes
X0 = [0;0;0;0;0;0;0];
sol_hinf = lsim(sys_hinf,u,T,X0);

sys_open = ss(h2.A,h2.Bd,Cz,[]);
X0 = [0;0;0;0];
u = Wd*dalpha_bar;
sol_open = lsim(sys_open,u,T,X0);

%  H2 Plots
limit = ones(N,1);
figure(4); clf;
% Subplot 1
subplot(2, 1, 1);hold on; grid on
plot(T,sol_h2(:,1),'b')
plot(T,sol_open(:,1),'r')
% plot(T,limit,LineWidth=2,Color='r')
% plot(T,-limit,LineWidth=2,Color='r')
title('Flight Path Angle Variation (H2)');
% ylim([-1.2 1.2])

% Subplot 2
subplot(2, 1, 2);hold on; grid on
plot(T,sol_h2(:,2),'b')
plot(T,sol_open(:,2),'r')
% plot(T,limit,LineWidth=2,Color='r')
% plot(T,-limit,LineWidth=2,Color='r')
title('Flight Velocity Variation');
% ylim([-1.2 1.2])

%  Hinf Plots
figure(5); clf;
% Subplot 1
subplot(2, 1, 1);hold on; grid on
plot(T,sol_hinf(:,1),'b')
plot(T,sol_open(:,1),'r')
% plot(T,limit,LineWidth=2,Color='r')
% plot(T,-limit,LineWidth=2,Color='r')
title('Flight Path Angle Variation (Hinf)');
% ylim([-1.2 1.2])

% Subplot 2
subplot(2, 1, 2);hold on; grid on
plot(T,sol_hinf(:,2),'b')
plot(T,sol_open(:,2),'r')
% plot(T,limit,LineWidth=2,Color='r')
% plot(T,-limit,LineWidth=2,Color='r')
title('Flight Velocity Variation');
% ylim([-1.2 1.2])
