function Thrust_Moment = ComputePropEffect(u)
persistent PropellerData persistentFlag
if isempty(persistentFlag)
    persistentFlag = 1;
    PropellerData = load_PropDat;
end

V = u(1);
RPM = u(2);

Thrust_Moment = zeros(2,1);
Thrust_Moment(:,1) = PropellerData(V,RPM);