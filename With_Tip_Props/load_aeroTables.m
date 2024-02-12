function aeroTables = load_aeroTables

% ==============================================================================================
% Step 1:
% -------
%    Function to read in all the aero coefficients:
%
%        CFx,CFy,CFz Coefficient of forces in body axis
%        CMx,CMy,CMz Coefficient of monents in body axis
%
%   All the above 9 are in general dependent on Vt, alp, bet, p, q, r, e.g., CFx(Vt,alp,bet,p,q,r).
%
%   We can use the following linear approximations:
%       CFx = CFx(Vt,alp,bet,p,q,r) + CFx_p(Vt,alp,bet,p,q,r)*dp +  CFx_q(Vt,alp,bet,p,q,r)*dq + CFx_r(Vt,alp,bet,p,q,r)*dr
%
%   Each coefficient is evaluated over a 3D mesh in (Vt,alp,bet).
%   We can consider:
%
%        Vtmin <= Vt <= Vtmax -- within valid Re.
%         -10  <= alpha <= 10 -- prestall
%         -15  <= beta <= 15  -- 
%
%   We can use SU2 to compute steady-state CFx(Vt,alp,bet), and OpenVSP to compute
%   derivatives w.r.t p,q,r.
%   
%   The 3D mesh in (Vt,alp,bet) for SU2 can be sparse -- depending on how
%   many runs you can make. We do not have any deadline ... but two/three
%   weeks is acceptable. The 3D mesh for OpenVSP can be dense.
%
%   Save each coefficient table in a separate data file -- e.g. CFx.csv for CFx(Vt,alp,bet)
% ==============================================================================================

% ==============================================================================================
% Step 2:
% -------
%   Read the .csv data file using matlab command readmatrix() and construct
%   griddedInterpolant object.
%
%   For example if CL0(alpha,beta) is stored in a CL0.csv file, it can be loaded
%   as:
%
%       data = readmatrix('CL0.csv');
%
%   then convert it to an interpolant object using aeroTables.CL0 = griddedInterpolant(...).
% 
%   This will be clear when we have the data available.
%
%
%   The return variable is a data structure aeroTables.(coeff) for each aero coefficients.
% ==============================================================================================
%% Load Coefficients
load('BiomT1WithPropCoeff_13FEB.mat', 'DATA_WITH_PROP');
alpha_values = 1:2:5;
beta_values = -2:2:2;
rrpm = linspace(1500,4000,5);
lrpm = linspace(1500,4000,5);
elevator = -2:2:2;
DATA = DATA_WITH_PROP;
[A,B,C,D,E] = ndgrid(alpha_values,beta_values,rrpm,lrpm,elevator);
data = DATA(:,:,:,:,:,1:6,:);
aeroTables = griddedInterpolant(A,B,C,D,E,data);
end
