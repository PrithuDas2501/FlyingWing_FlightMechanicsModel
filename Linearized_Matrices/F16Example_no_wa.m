clear; clc;
model = load("F16_julia");

ix = [5,7,8,11];
iu = [1,2,5];

A = model.A(ix,ix);
Bu = model.Bu(ix,iu);
[nx,nu] = size(Bu);

% Controlled variable: [Gamma,Vt]
d2r = pi/180;
Wz = diag([1/(5*d2r) 1/100]); % Scale the velocity and flight path angle.
Cz = zeros(1,4);
Cz(1,2) = 1; % Velocity
nz = size(Cz,1);

% Assume disturbance to impact Vdot, alphadot, and qdot
Bd = model.Bd(ix);
nd = size(Bd,2);

Dd = zeros(nz,nd); % Disturbance doesn't affect z,

% Other parameters.
Wd = 0.000001*eye(nd); % Wind gust scaling.
gam_clp = 1;   % Closed-loop performance.   

Wxf = diag([1/1000,1/25,1/10]);
Cxf = Wxf*[zeros(nu,nx) eye(nu)];

%% Spring Mass Damper
% A = [0 1;-1 -1];
% Bu = [0;1];
% Bd = Bu;
% Cz = [1 0];
% Dd = 0
% 
% [nx,nu] = size(Bu);
% nd = size(Bd,2);
% nz = size(Cz,1);
% Cxf = [zeros(nu,nx) eye(nu)];
% 
% gam_clp = 1;
% Wd = 0.1;


%% Solve the problem
cvx_begin sdp
cvx_solver mosek
variable Y(nx,nx) semidefinite
variable V(nu,nx)
variable alp(nu) nonnegative
variable kappa(nu) nonnegative
variable gamma_xf(nu)  nonnegative

s = 1;

P = [Y*A Y*Bu;
     s*V  -s*diag(alp)];

X = blkdiag(Y,s*eye(nu,nu));

%% Hinf CLP
% F11 = P+P';
% F12 = [Y*Bd;zeros(nu,nd)];
% F13 = [Cz';zeros(nu,nz)];
% F22 = -gam_clp*inv(Wd^2);
% F23 = [Wd'*Dd'];
% F33 = -gam_clp*eye(nz,nz);
% 
% [F11 F12 F13;
%  F12' F22 F23;
%  F13' F23' F33] <= 0

%% H2 CLP
F11 = P+P';
F13 = [Cz';zeros(nu,nz)];

% Without Wa
% F12 = [Y*Bd;zeros(nu,nd)];
% F22 = -inv(Wd^2);

% With Wa
F12 = [Y*Bd Y*Bu;zeros(nu,nd) zeros(nu,nu)];
F22 = -blkdiag(inv(Wd^2),diag(kappa));

[F11 F12; F12' F22] <= 0

variable Qz(nz,nz)
[Qz [Cz zeros(1,nu)];
[Cz zeros(1,nu)]' X] >= 0
trace(Qz) <= gam_clp
%% Actuator mag limit

variable Qu(nu,nu) semidefinite

[Qu Cxf;
 Cxf' X] >= 0

Qu <= diag(gamma_xf)

minimize norm(alp,2)  + norm(gamma_xf,2) + norm(gamma_xf,2)

cvx_end


