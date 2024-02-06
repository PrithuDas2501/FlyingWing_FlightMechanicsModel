%% Information about Variables
%% x = [x,y,z,vx,vy,vz,phi,theta,psi,p,q,r]'
%% u = [RRPM,LRPM,Elevator,Outeron,Inneron,GustX,GustY,GustZ]'
%% y = [x,y,z,v_total,aoa,beta,phi,theta,psi,gamma,p,q,r,ax,ay,az]


%% Loading the Exhaustive Data
sys = load('Trim_WithGust_6thFeb.mat','sys');
sys = sys.sys;
%% To access the Entire set of Matrices: sys.a,sys.b,sys.c,sys.d

%% Accessing only Lateral Mode Quantities along with Disturbance Matrix B_d and D_d (Can be tailored to our needs accordingly)
ixLongi = [5,7,9,10,12];    % [Vy, Phi, Psi, p, r]                         accessed from x
iuLongi = [1,2,3,4,5];      % [RRPM, LRPM, Elevator, Outeron, Inneron]     accessed from u
iudLongi = [6,7,8];         % [GustX, GustY, GustZ]                        accessed from u
iyLongi = [6,7,9,11,13,15]; % [Beta, Phi, Psi, p, r, ay]                   accessed from y

A = sys.a(ixLongi,ixLongi);
B = sys.b(ixLongi,iuLongi);
B_d = sys.b(ixLongi,iudLongi);
C = sys.c(iyLongi,ixLongi);
D = sys.d(iyLongi,iuLongi);
D_d = sys.d(iyLongi,iudLongi);

%sysLongi2 = ss(A,B,C,D);