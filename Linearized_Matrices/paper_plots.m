clc; clear; 

h2 = load("h2_design.mat");
hinf = load('hinf_design.mat');
%%
d2r = pi/180;
A = h2.Aclp;
B = [h2.Bd h2.Bu];
B = [B; zeros(3,4)];
Scale = [1/(0.5*d2r) 0; 0 1/10];
%Scale = eye(2);
Cz = Scale*[1 0 -1 0; 0 1 0 0];
C = [Cz zeros(2,3);zeros(3,4) eye(3)];
sys = ss(A,B,C,[]);
T = 0:0.01:1000;
N = length(T);
dalpha = (rand(N,1)-0.5)*2;
dalpha_bar = dalpha/(trapz(T,dalpha.^2))^0.5;
Wa = diag(h2.kappa.^-0.5);
wa = (rand(N,3)-0.5)*2;
wa_bar = wa/(trapz(T,(wa.^2)*[1;1;1])^0.5);
u = [dalpha_bar wa_bar*Wa]; 
X0 = [0;0;0;0;0;0;0];
sol_h2 = lsim(sys,u,T,X0);


A = hinf.Aclp;
B = [hinf.Bd h2.Bu];
B = [B; zeros(3,4)];
Cz = Scale*[1 0 -1 0; 0 1 0 0];
C = [Cz zeros(2,3);zeros(3,4) eye(3)];
sys = ss(A,B,C,[]);
T = 0:0.01:1000;
N = length(T);
dalpha = (rand(N,1)-0.5)*2;
dalpha_bar = dalpha/(trapz(T,dalpha.^2))^0.5;
Wa = diag(hinf.kappa.^-0.5);
wa = rand(N,3);
wa_bar = wa/(trapz(T,(wa.^2)*[1;1;1])^0.5);
u = [dalpha_bar wa_bar*Wa]; 
X0 = [0;0;0;0;0;0;0];
sol_hinf = lsim(sys,u,T,X0);
%% H2 Plots
limit = ones(N,1);
figure;
% Subplot 1
subplot(2, 1, 1);hold on; grid on
plot(T,sol_h2(:,1),'b')
plot(T,limit,LineWidth=2,Color='r')
plot(T,-limit,LineWidth=2,Color='r')
title('Flight Path Angle Variation');
ylim([-1.2 1.2])

% Subplot 2
subplot(2, 1, 2);hold on; grid on
plot(T,sol_h2(:,2),'b')
plot(T,limit,LineWidth=2,Color='r')
plot(T,-limit,LineWidth=2,Color='r')
title('Flight Velocity Variation');
ylim([-1.2 1.2])
%% Hinf Plots
figure;
% Subplot 1
subplot(2, 1, 1);hold on; grid on
plot(T,sol_hinf(:,1),'b')
plot(T,limit,LineWidth=2,Color='r')
plot(T,-limit,LineWidth=2,Color='r')
title('Flight Path Angle Variation');
ylim([-1.2 1.2])

% Subplot 2
subplot(2, 1, 2);hold on; grid on
plot(T,sol_hinf(:,2),'b')
plot(T,limit,LineWidth=2,Color='r')
plot(T,-limit,LineWidth=2,Color='r')
title('Flight Velocity Variation');
ylim([-1.2 1.2])
%%
fs = 14;

% Plot control rate
figure(1); clf;
labels = {'$T$','$\delta_e$','$\delta_{lef}$'};
stem(h2.omc,'r','filled','MarkerSize',8,'LineWidth', 1); hold on;
stem(hinf.omc,'k-.','filled','MarkerSize',8,'LineWidth', 2);

set(gca,'yscal','log');
xaxisproperties= get(gca, 'XAxis');
xaxisproperties.TickLabelInterpreter = 'latex';
a = get(gca,'XTickLabel'); set(gca,'XTickLabel',a,'fontsize',12)

title('Minimum Actuator Cut-off Frequencies (rad/s).','Interpreter','latex','FontSize',fs);
xticks([1,2,3])
xticklabels(labels);
xlabel('Actuator');

legend({'$\mathcal{H}_2$','$\mathcal{H}_\infty$'},'Interpreter','latex')
grid on;

print -depsc ../images/act_cutoff.eps

% Plot DC gain
figure(2); clf;
labels = {'$T$','$\delta_e$','$\delta_{lef}$'};

for i = 1:3
    h2.hinf_norms(i) = norm(h2.act(i,:),inf);
    hinf.hinf_norms(i) = norm(hinf.act(i,:),inf);
end

stem(h2.hinf_norms,'r','filled','MarkerSize',8,'LineWidth', 1); hold on;
stem(hinf.hinf_norms,'k-.','filled','MarkerSize',8,'LineWidth', 2);

set(gca,'yscal','log');
xaxisproperties= get(gca, 'XAxis');
xaxisproperties.TickLabelInterpreter = 'latex';

title('Actuator $\mathcal{H}_\infty$ norms.','Interpreter','latex','FontSize',fs);
xticks([1,2,3])
xticklabels(labels);
xlabel('Actuator');
a = get(gca,'XTickLabel'); set(gca,'XTickLabel',a,'fontsize',12)

legend({'$\mathcal{H}_2$','$\mathcal{H}_\infty$'},'Interpreter','latex')
grid on;
print -depsc ../images/act_hinfnorms.eps

% Actuator noise
figure(3); clf;
labels = {'$T$','$\delta_e$','$\delta_{lef}$'};

stem(1./sqrt(h2.kappa),'r','filled','MarkerSize',8,'LineWidth', 1); hold on;
stem(1./sqrt(hinf.kappa),'k-.','filled','MarkerSize',8,'LineWidth', 2);

set(gca,'yscal','log');
xaxisproperties= get(gca, 'XAxis');
xaxisproperties.TickLabelInterpreter = 'latex';

title('Actuator Noise Scaling ($1/\sqrt{\kappa}$).','Interpreter','latex','FontSize',fs);
xticks([1,2,3])
xticklabels(labels);
xlabel('Actuator');
a = get(gca,'XTickLabel'); set(gca,'XTickLabel',a,'fontsize',12)

legend({'$\mathcal{H}_2$','$\mathcal{H}_\infty$'},'Interpreter','latex')
grid on;
print -depsc ../images/act_noise.eps
