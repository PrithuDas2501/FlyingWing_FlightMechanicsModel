function inertiaGeom = load_inertiaGeom()

%% SORTED
inertiaGeom.mass = 5;       % Mass (Kg)

%% SORTED %% Mult by Mass
inertiaGeom.Ixx =  0.200127*inertiaGeom.mass;      % Ixx moment of inertia (kg-m^2)
inertiaGeom.Iyy = 0.013351*inertiaGeom.mass;       % Iyy moment of inertia (kg-m^2)
inertiaGeom.Izz = 0.212504*inertiaGeom.mass;       % Izz moment of inertia (kg-m^2)
inertiaGeom.Ixz = -0.000026*inertiaGeom.mass;       % Ixz moment of inertia (kg-m^2)
inertiaGeom.inertiaMatrix = [inertiaGeom.Ixx 0 inertiaGeom.Ixz ; 0 inertiaGeom.Iyy 0 ; inertiaGeom.Ixz 0 inertiaGeom.Izz] ;

%% SORTED
inertiaGeom.wingSpan = 2.2;      % Wing Span (m)
inertiaGeom.wingArea = 0.28793;  % Wing Area (m^2)
S = 0.28793;
%% SORTED
ChordData = 0.001*readmatrix('ChordVsSpanTable.xlsx');
MAC = 0;
for i = 2:19
    MAC = MAC + (2/S)*(ChordData(i+1,1) - ChordData(i,1))*(ChordData(i+1,2)^3 - ChordData(i,2)^3)/(3*(ChordData(i+1,2) - ChordData(i,2)));
end

inertiaGeom.meanAerodynamicChord = MAC;  % mean aerodynamic chord of the wing (m) 
end