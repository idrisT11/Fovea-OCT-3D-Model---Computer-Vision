%% COMPUTE THE GVF OF THE edge map imEdgeMap

function [u,v] = GVFAlgorithm(f, mu, ITER)

% Normaliser la carte de contours
vmin  = min(f(:));
vmax  = max(f(:));
if vmin ~= 0 || vmax ~= 1
    f = (f-vmin)/(vmax-vmin);  % Normalize f to the range [0,1]
end

% Calculer le gradient de la carte de contours - ajouter un bordage
f = addBorders(f);        
[fx,fy] = gradient(f);    

% initialiser le GVF
u = fx; v = fy;             % Initialiser 
fm2 = fx.*fx + fy.*fy;      % module au carré du gradient

% Algorithme itératif
for i=1:ITER,
  u = updateBorders(u);
  v = updateBorders(v);
  u = u + mu*4*del2(u) - fm2.*(u-fx);
  v = v + mu*4*del2(v) - fm2.*(v-fy);
end

u = suppressBorder(u);
v = suppressBorder(v);
end

%% --------------------------------------------------------

function B = addBorders(A)

[H,W] = size(A);
y = 2:H+1;
x = 2:W+1;
B = zeros(H+2,W+2);
B(y,x) = A;
B([1 H+2],[1 W+2]) = B([3 H],[3 W]);  % Coins
B([1 H+2],x) = B([3 H],x);          % Bords droit et gauches
B(y,[1 W+2]) = B(y,[3 W]);          % Bords sup et inf
end

%% --------------------------------------------------------

function B = updateBorders(A)

[H,W] = size(A);

if (H<3 | W<3) 
    error('Taille matrice minimale : 3x3');
end

y = 2:H-1;
x = 2:W-1;
B = A;
B([1 H],[1 W]) = B([3 H-2],[3 W-2]);  % Coins
B([1 H],x) = B([3 H-2],x);          % Bords droit et gauches
B(y,[1 W]) = B(y,[3 W-2]);          % Bords sup et inf
end

%% --------------------------------------------------------

function B = suppressBorder(A)

[H,W] = size(A);

if (H<3 | W<3) 
    error('Taille matrice minimale : 3x3');
end

y = 2:H-1;
x = 2:W-1;
B = A(y,x);
end