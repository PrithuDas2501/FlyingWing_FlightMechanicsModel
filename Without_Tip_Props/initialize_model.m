clear;clc; 

% create flag to load the right parameters: based on the right model
% Load inertia and geometry properties

inertiaGeom = load_inertiaGeom();
g = 9.81;

PropellerData = load_PropDat();

% create flag to load the right aerotable: based on the right model
% Load aerodynamics
aeroTables = load_aeroTables(); 

% Trim conditions
d2r = pi/180;
zbar = 100; % altitude in meters
alpha0 = 0*d2r;
beta0 = 0*d2r;
phi0 = 0;
theta0 = 0;
psi0 = 0;
gamma0 = 0;
omega0 = [0 0 0];
linaccl0 = [0 0 0]; 

[rho, SOS] = atmosphere(zbar);
u0 = 25; % = 80.64 km/h ... too high?
v0  = 0;
w0 =  0;
Vt0 = norm([u0 v0 w0]);

qbar = 0.5*rho*Vt0^2;


x0 = [0 0 zbar u0 v0 w0 0 0 0 0 0 0];
dx0 = [u0 v0 w0 0 0 0 0 0 0 0 0 0];
y0 = [0 0 zbar Vt0 alpha0 beta0 phi0 theta0 psi0 gamma0 omega0 linaccl0];
U0 = [0 0 0 2000]; % Guess for trim U0, U0 = 
%% Trim
% Freeze certain values of y0
iy = [3 6 7 9 10];
iu = [];
% Trim the vehicle -- cannot impose state and control constraints. Have to
% resort to fmincon <-- TODO.
% Can't satisfy alphabar constraint. Need to look into it.
%options = optimoptions(@fmincon, 'MaxIterations', 3000);
%BiomT1_NOPROP_Model([],[],[],'compile');
options = [0 1e-4 1e-4 1e-4 0 0 0 0 0 0 0 0 0 10000 0 1e-8 0.1 0];
BiomT1_NOPROP_Model([],[],[],'compile');
[xTrimRet,uTrim2,yTrim,dxTrim,options] = trim('BiomT1_NOPROP_Model',x0',U0',y0',[],iu,iy,dx0',[1:12],options) % name of the sim file ,[],2:12
BiomT1_NOPROP_Model([],[],[],'term');
%%
%[uTrim2,fval,exitflag,output] = TrimWithoutProp(x0,y0)
%% Test Aerotables
Vt0 = yTrim(4);
alpha0 = yTrim(5);
beta0 = yTrim(6);
qbar = 0.5*rho*Vt0^2;
w = yTrim(11:13)'; 
r2d = 180/pi;
elevator = uTrim2(1)*r2d;
outeron = uTrim2(2)*r2d;
inneron = uTrim2(3)*r2d;
d = zeros(6,11);
d(:,:) = aeroTables(alpha0,beta0,inneron,outeron,elevator)
%%
inp = [Vt0 0*d2r 0 0 0 0 qbar 0 0 0];%elevator outeron inneron];
FMaero = computeAeroFM(inp);
disp(FMaero); 
%% Linearize 
sys = linmod('BiomT1_NOPROP_Model',xTrimRet,uTrim2);
ixLongi = [10,11,12];
iuLongi = [1,2,3,4];
iyLongi = [4,5,8,10,12,14,16]; % Vt,alp,th,gam,q,ax,az

A = sys.a(ixLongi,ixLongi);
B = sys.b(ixLongi,iuLongi);
C = sys.c(iyLongi,ixLongi);
D = sys.d(iyLongi,iuLongi);

sysLongi2 = ss(A,B,C,D);


