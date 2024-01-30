n = 20;
u = linspace(20,40,n);
ClCd = zeros(1,10);
RPM = zeros(1,10);
for i = 1:n
    y = Cl_By_Cd(u(i),inertiaGeom,aeroTables);
    RPM(i) = y(2);
    ClCd(i) = y(1);
end
%%
figure
grid on
hold on
xlabel('Velocity')
ylabel('Cl/Cd')
plot(u,ClCd,LineWidth=2);
%%
figure
grid on
hold on
xlabel('Velocity')
ylabel('(Cl/Cd)^3/2')
plot(u,ClCd.^(3/2),LineWidth=2);
%%
figure
grid on
hold on
xlabel('Velocity')
ylabel('RPM Trim')
plot(u,RPM,LineWidth=2);
%%
y = Cl_By_Cd(20,inertiaGeom,aeroTables)
%%
function y = Cl_By_Cd(u0,inertiaGeom,aeroTables)
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
%u0 = 21.5; 
v0  = 0;
w0 =  0;
Vt0 = norm([u0 v0 w0]);

qbar = 0.5*rho*Vt0^2;


x0 = [0 0 zbar u0 v0 w0 0 0 0 0 0 0];
dx0 = [u0 v0 w0 0 0 0 0 0 0 0 0 0];
y0 = [0 0 zbar Vt0 alpha0 beta0 phi0 theta0 psi0 gamma0 omega0 linaccl0];
U0 = [0 0 0 1000]; % Guess for trim U0, U0 = 
%% Trim
iy = [3];
iu = [];
options = [0 1e-4 1e-4 1e-4 0 0 0 0 0 0 0 0 0 10000 0 1e-8 0.1 0];
BiomT1_NOPROP_Model([],[],[],'compile');
[xTrimRet,uTrim2,yTrim,dxTrim,options] = trim('BiomT1_NOPROP_Model',x0',U0',y0',[],iu,iy,dx0',1:12,options); % name of the sim file ,[],2:12
BiomT1_NOPROP_Model([],[],[],'term');
%% Calculating Cl/Cd (For Range)
cbar = inertiaGeom.meanAerodynamicChord;
tf = cbar/(2*u0);
FMAero_Coeff = zeros(6,11);
FMAero_Coeff(:,:) = aeroTables(yTrim(5)/d2r,yTrim(6)/d2r,uTrim2(3)/d2r,uTrim2(2)/d2r,uTrim2(1)/d2r); %aeroTables(alpha*r2d,beta*r2d,inneron*r2d,outeron*r2d,elevator*r2d);
FlightParams = [1; yTrim(5); yTrim(6); yTrim(11)*tf; yTrim(12)*tf; yTrim(13)*tf; 0; 0; uTrim2(2); uTrim2(3); uTrim2(1)]; % 7th and 8th Index kept as zero as we are ignoring effect of mach number and velocity
FMAero_TotalCoeff = FMAero_Coeff*FlightParams;
X = ([cos(yTrim(5)), sin(yTrim(5)); -sin(yTrim(5)), cos(yTrim(5))]*[FMAero_TotalCoeff(1);FMAero_TotalCoeff(3)])';

y = X(2)/X(1);
y = [y uTrim2(4)];
end