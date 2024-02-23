model = load("F16_julia");

ix = [5,7,8,11];
iu = [1,2,5];

A = model.A(ix,ix);
Bu = model.Bu(ix,iu);
[nx,nu] = size(Bu);

Bd = [0;1;0;0]; 

Cz = zeros(2,4);
Cz(1,1) = 1; Cz(1,3) = -1; % Gamma
Cz(2,2) = 1;

sys_olp = ss(A,Bd,Cz,[]);
