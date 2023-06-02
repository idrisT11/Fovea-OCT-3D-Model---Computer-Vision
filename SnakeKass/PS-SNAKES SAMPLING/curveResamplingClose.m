function [x,y] = curveResamplingClose(x0,y0,pas)

x0 = x0(:);
y0 = y0(:);

ind = find(x0(1:end-1) ~= x0(2:end) | y0(1:end-1) ~= y0(2:end) );
x0 = x0(ind);
y0 = y0(ind);


% interpoler - on calcul le paramètre s de la courbe
s  = sqrt( ([x0(2:end) ]- x0(1:end-1)).^2 + ([y0(2:end)]- y0(1:end-1)).^2);
s = [0 ; s];for l = 2:length(s), s(l) = s(l)+s(l-1);end

% Et on interpole pour avoir des points distants de pas
x = interp1(s,x0, (0:pas:max(s))');
y = interp1(s,y0, (0:pas:max(s))');

% % On calcule le dernier point
% if max((0:pas:max(s)))< max(s)
%     x = [x ; x0(end)];
%     y = [y ; y0(end)];
% end

