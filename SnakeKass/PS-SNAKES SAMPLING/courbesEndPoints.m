function [x,y,R]  = courbesEndPoints(x,y,R,x1,y1,x2,y2,pas)

N2 = round(length(x)/3);

% Find the closest points
ind = find(sqrt((x(1:N2)-x1).^2 + (y(1:N2)-y1).^2) <pas);
if ~isempty(ind)
    ind1 = ind(end);
    x = x(ind1:end);
    y = y(ind1:end);
    R = R(ind1:end);
else
    x = [x1 ; x];
    y = [y1 ; y];
    R = [R(1) ; R];
end

% Find the closest points
ind  = find(sqrt((x(end-N2:end)-x2).^2 + (y(end-N2:end)-y2).^2)<pas);
ind  = length(x) -N2 + ind -1;

if ~isempty(ind)
    ind2 = ind(1);
    x = x(1:ind2);
    y = y(1:ind2);
    R = R(1:ind2);
else
    x = [x ; x2];
    y = [y ; y2];
    R = [R ; R(end)];
end