function [px,py,imEdgeMap] = GVFCompute(I, mode,mu, nbGVFiter,sigma)

m = min(I(:));
M = max(I(:));
I = (I-m)/(M-m);

% Calculer la carte des contours
if mode == 1
%     disp('        Compute edge map ...');
    if sigma > 0
        h2 = ceil(3*sigma); h = 2*h2+1; 
        H = fspecial('gaussian',[h h],sigma);
        im = imfilter(I,H);         % Apply a Gaussian filter
    else
        im = I;
    end
    [imx,imy] = gradient(im);                 % Compute the edge 
    img  = sqrt(imx.^2 + imy.^2);
    m = min(img(:));
    M = max(img(:));
    imEdgeMap = (img-m)/(M-m);
elseif mode == 2
    imEdgeMap = I; 
elseif mode == 3
    imEdgeMap = 1-I;
end

% Calculer le GVF
% disp('        Compute GVF ...');
[u,v] = GVFAlgorithm(imEdgeMap, mu, nbGVFiter);

% disp(' Nomalizing the GVF external force ...');
mag = sqrt(u.*u+v.*v);
px = u./(mag+1e-10); py = v./(mag+1e-10); 

