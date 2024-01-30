function PropData = load_PropDat
load("PropellerData22Jan.mat","PropellerData");
Vf_values = [21.5*0.9 21.5 21.5*1.1];
RPM_values = linspace(2800,4000,20);
[A,B] = ndgrid(Vf_values,RPM_values);
PropData = griddedInterpolant(A,B,PropellerData);
end