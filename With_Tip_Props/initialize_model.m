clear;clc; 

% create flag to load the right parameters: based on the right model
% Load inertia and geometry properties

inertiaGeom = load_inertiaGeom();
g = 9.81;


RPM_Values = load("Propeller_Data1.mat", "RPM_Values");
Thrust_Values = load("Propeller_Data1.mat", "Thrust_Values");
Power_Values = load("Propeller_Data1.mat", "Power_Values");


% create flag to load the right aerotable: based on the right model
% Load aerodynamics
aeroTables = load_aeroTables(); 

% Trim conditions
d2r = pi/180;
zbar = 100; % altitude in meters
alpha0 = 0;
beta0 = 0;
phi0 = 0;
theta0 = 0;
psi0 = 0;
gamma0 = 0;
omega0 = [0 0 0];
linaccl0 = [0 0 0]; 

[rho, SOS] = atmosphere(zbar);
u0 = 21.5; % = 80.64 km/h ... too high?
v0  = 0;
w0 =  0;
Vt0 = norm([u0 v0 w0]);

qbar = 0.5*rho*Vt0^2;


x0 = [0 0 zbar u0 v0 w0 0 0 0 0 0 0];
y0 = [0 0 zbar Vt0 alpha0 beta0 phi0 theta0 psi0 gamma0 omega0 linaccl0];
U0 = [10 10 0]; % Guess for trim U0, U0 = 

%% Test Aerotables
%Vt0 = 100;
alpha0 = 0*d2r;
beta0 = 0*d2r;
qbar = 0.5*rho*Vt0^2;
w = [0 0 0]; 
rrpm = 3000;
lrpm = 3000;
elevator = -4.48*d2r;

inp = [Vt0 alpha0 beta0 w qbar rrpm lrpm elevator];
FMaero = computeAeroFM(inp);
disp(FMaero);

%% Trim
% Freeze certain values of y0
iy = [3 4 6 7 9 10 11:13 14:16];
iu = [];
% Trim the vehicle -- cannot impose state and control constraints. Have to
% resort to fmincon <-- TODO.
% Can't satisfy alphabar constraint. Need to look into it.
[xTrimRet,uTrim2,yTrim,dxTrim] = trim('BiomT1_WITHPROP_Model',x0',U0',y0',[],iu,iy,[],2:12) % name of the sim file

%% Linearize 
sys = linmod('BiomT1_WITHPROP_Model',xTrimRet,uTrim2);

ixLongi = [4,6,8,11];
iuLongi = [1,2,3];
iyLongi = [4,5,8,10,12,14,16]; % Vt,alp,th,gam,q,ax,az

A = sys.a(ixLongi,ixLongi);
Btemp = sys.b(ixLongi,iuLongi);
B = [(Btemp(:,1) + Btemp(:,2)) Btemp(:,3)];
C = sys.c(iyLongi,ixLongi);
Dtemp = sys.d(iyLongi,iuLongi);
D = [(Dtemp(:,1) + Dtemp(:,2)) Dtemp(:,3)];

sysLongi2 = ss(A,B,C,D);
 