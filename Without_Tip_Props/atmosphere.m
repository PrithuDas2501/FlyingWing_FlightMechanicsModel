function [rho, SOS] = atmosphere(altitude)

% This compute air density (rho) and speed of sound at a given altitude
% using a standard atmosphere model.

% Input: altitude (positive up) in meters
% Output: density (rho, kg/m^3) and speed of sound (m/s) 

% Ref. D. Schmidt, Modern Flight Dynamics, Appendix A (p. 809)

% The model is in imperial units, so we convert to imperial at the
% beginning and then back to metric at the end

altitude = altitude/0.3048 ;  % convert altitude to ft

if(altitude < 36089)
    T = 518.69 - (3.5662*10^-3)*altitude ;
    rho = (6.6277*10^-15)*T^4.256 ;
    SOS = 49.021*sqrt(T) ;
elseif(altitude < 65617)
    T = 389.99 ;
    p = 2678.4*exp((-4.8063)*10^-5*altitude) ;
    rho = 1.4939*10^-6*p ;
    SOS = 49.021*sqrt(T) ;
else
    T = 389.99 + 5.4864*10^-4*(altitude-65617) ;
    rho = (2.2099*10^87)*T^-35.164 ;
    SOS = 49.021*sqrt(T) ;
end

% Convert back to metric units
SOS = SOS*0.3048 ;  % m/s
rho = rho*515.379 ;  % kg/m^3








