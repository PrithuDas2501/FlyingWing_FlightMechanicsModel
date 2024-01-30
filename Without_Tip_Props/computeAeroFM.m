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
elevator = u(8);
outeron = u(9);
inneron = u(10);
disp(u);

%% Retrieve some necessary geometry parameters
cbar = inertiaGeom.meanAerodynamicChord ;
b = inertiaGeom.wingSpan;
Sw = inertiaGeom.wingArea;
tf = cbar/(2*Vt);

%% Interpolate all aero data for a given Mach and alpha (in degrees).
FMAero_Coeff = zeros(6,11);
FMAero_Coeff(:,:) = aeroTables(alpha*r2d,beta*r2d,inneron*r2d,outeron*r2d,elevator*r2d);
FlightParams = [1; alpha; beta; p*tf; q*tf; r*tf; 0; 0; outeron; inneron; elevator]; % 7th and 8th Index kept as zero as we are ignoring effect of mach number and velocity
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

