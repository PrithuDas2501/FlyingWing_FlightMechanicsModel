%% Minimizing the H2 norm of the actuator.

clear all;
d2r = pi/180;

model = load("F16_julia");

ix = [5,7,8,11];
iu = [1,2,5];

A = model.A(ix,ix);
Bu = model.Bu(ix,iu);
[nx,nu] = size(Bu);

Bd = [0;1;0;0];%model.Bd(ix);
nd = size(Bd,2);

%% Try some frequency dependent performance specification.
% sysOL = ss(A,[Bd Bu],eye(nx),[]);
%
% % Set up for optimization
% d = icsignal(1); %  disturbance
% u =  icsignal(3); % Control signal (T,dele,dlef)
% z = icsignal(2);  % controlled signal
% xOL = icsignal(nx); % States
%
% % Setup frequency dependent weights
% s = tf('s');
% Wz = blkdiag([1/100/(s/.5+1),(1/5/d2r)/(s/1+1)]);
%
% M = iconnect;
% M.Input = [d;u];
% M.Output = z;
% M.Equation{1} = equate(xOL,sysOL*M.Input);
% M.Equation{2} = equate(z,[xOL(2);xOL(1)-xOL(3)])

%%

% Controlled variable: [Gamma,Vt]
d2r = pi/180;
Wz = diag([1/(5*d2r) 1/10]); % Scale the flight path angle and velocity
Cz = zeros(2,4);
Cz(1,1) = 1; Cz(1,3) = -1; % Gamma
Cz(2,2) = 1; % Velocity
Cz = Wz*Cz;  % Normalize Cz.
nz = size(Cz,1);

Dd = zeros(nz,nd); % Disturbance doesn't affect z,

% Other parameters.
Wd = 0.1*eye(nd); % Wind gust scaling.
gam_clp = 1;   % Closed-loop performance.

%% Solve the problem
%addpath('C:\Users\sudip\OneDrive\Documents\ActuatorDegradationCDC\cvx');
%addpath('C:\Users\sudip\OneDrive\Documents\ActuatorDegradationCDC\MOSEK-MATLAB-master\');
addpath('C:\Users\sudip\OneDrive\Documents\MATLAB\cvx')
%cvx_setup
cvx_begin sdp quiet
cvx_solver sedumi
variable Y(nx,nx) semidefinite
variable V(nu,nx)
variable kappa(nu) nonnegative
variable omc(nu) nonnegative

P = [Y*A Y*Bu;
    V  -diag(omc)];

X = blkdiag(Y,eye(nu));

hinf = true;

if hinf
    % Hinf CLP performance
    disp('Hinf design');
    saveFile = 'hinf_design.mat';
    F11 = P+P';
    F12 = [Y*Bd Y*Bu;zeros(nu,nd) zeros(nu,nu)];
    F13 = [Cz';zeros(nu,nz)];
    F22 = -gam_clp*blkdiag(inv(Wd^2),diag(kappa));
    F23 = [Wd'*Dd';zeros(nu,nz)];
    F33 = -gam_clp*eye(nz,nz);

    [F11 F12 F13;
        F12' F22 F23;
        F13' F23' F33] <= 0

else
    % H2 CLP Performance
    disp('H2 design');
    saveFile = 'h2_design.mat';

    F11 = P+P';
    F13 = [Cz';zeros(nu,nz)];
    F12 = [Y*Bd Y*Bu;zeros(nu,nd) zeros(nu,nu)];
    F22 = -blkdiag(inv(Wd^2),diag(kappa));

    [F11 F12; F12' F22] <= 0

    variable Qz(nz,nz) semidefinite
    [Qz [Cz zeros(nz,nu)];
        [Cz zeros(nz,nu)]' X] >= 0
    trace(Qz) <= gam_clp
end


%% Actuator mag limit
AF = -diag(omc);
BF = V;
Wu = diag([1/1000,1,1]);
variable Q(nx,nx) semidefinite
variable gamF nonnegative
variable gamA nonnegative

[Q V';V eye(nu)] >= 0
minimize norm(omc,2) + 0.0000001*norm(kappa,2) + 0.0000001*trace(Q)

cvx_end

disp(cvx_optval)

act = ss(full(AF),V,eye(nu),[]);

disp(['act h2 norm: ',num2str(norm(act,2))]);

K = inv(diag(omc))*V;
disp('Controller Gain:')
disp(K);

disp('omc')
disp(omc)

disp('kappa')
disp(kappa)

Aclp= [A Bu;
    V  -diag(omc)];

save(saveFile); % Save it for plotting later.
