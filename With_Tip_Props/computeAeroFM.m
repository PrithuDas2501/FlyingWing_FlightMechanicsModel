function FMaero = computeAeroFM(u)

%% Loading Required Coefficients' Data
persistent aeroTables inertiaGeom persistentFlag r2d

if isempty(persistentFlag)
    persistentFlag = 1;
    aeroTables = load_aeroTables();
    inertiaGeom = load_inertiaGeom();
    r2d = 180/pi;
end

%% Unpack input vector (All angles In Rad)
Vt = u(1);
alpha = u(2); 
beta = u(3); 
p = u(4); 
q = u(5); 
r = u(6); 
qbar = u(7);
right_rpm = u(8);
left_rpm = u(9);
elevator = u(10);
disp(u);

%% Retrieve some necessary geometry parameters
cbar = inertiaGeom.meanAerodynamicChord ;
b = inertiaGeom.wingSpan;
Sw = inertiaGeom.wingArea;
tf = cbar/(2*Vt);

%% Interpolate all aero data for a given Mach and alpha (in degrees).
FMAero_Coeff = zeros(6,11);
FMAero_Coeff(:,:) = aeroTables(alpha*r2d,beta*r2d,right_rpm,left_rpm,elevator*r2d);
FlightParams = [1; alpha; beta; p*tf; q*tf; r*tf; 0; 0; elevator; 0; 0]; % 7th and 8th Index kept as zero as we are ignoring effect of mach number and velocity. Also Inneron and Outeron kept at 0
FMAero_TotalCoeff = FMAero_Coeff*FlightParams;
Factor_Matrix = [-1  0  0  0  0  0;
                  0  1  0  0  0  0;
                  0  0 -1  0  0  0;
                  0  0  0 -1  0  0;
                  0  0  0  0  1  0;
                  0  0  0  0  0 -1];
for i = 1:6
    if i>3
        Factor_Matrix(i,i) = Factor_Matrix(i,i)*qbar*Sw*b;
    else
        Factor_Matrix(i,i) = Factor_Matrix(i,i)*qbar*Sw;
    end
end

FMaero = Factor_Matrix*FMAero_TotalCoeff;
end

