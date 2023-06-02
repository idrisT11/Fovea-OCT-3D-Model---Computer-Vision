% -------------------------------------------------------------------------
%
%   Florence ROSSANT - SITe
%
%   Exatraction des passages par zéros
%
%   Entrées :
%       imf     : image du Laplacien
%       S       : seuil 
%
%   Sortie :
%       imout     : image binaire résultat (contours)
%
%
% -------------------------------------------------------------------------

function imout = extractionContoursLaplacien(imf,S)
[H,W] = size(imf);
imout = zeros(H,W);
for i=2:H-1
    for j=2:W-1
        if imf(i,j)<0 && imf(i,j+1)>0 && abs(imf(i,j)-imf(i,j+1))>S
            imout(i,j)=1;
        end
        if imf(i,j)<0 && && abs(imf(i,j)-imf(i,j-1))>S
            imout(i,j)=1;
        end
        if imf(i,j)<0 && imf(i+1,j)>0 && abs(imf(i,j)-imf(i+1,j))>S
            imout(i,j)=1;
        end
        if imf(i,j)<0 && imf(i-1,j)>0 && abs(imf(i,j)-imf(i-1,j))>S
            imout(i,j)=1;
        end
        if imf(i,j)==0
            if imf(i-1,j)<0 && imf(i+1,j)>0 && abs(imf(i-1,j)-imf(i+1,j))>2*S
                imout(i,j)=1;
            end
            if imf(i+1,j)<0 && imf(i-1,j)>0 && abs(imf(i-1,j)-imf(i+1,j))>2*S
                imout(i,j)=1;
            end
            if imf(i,j-1)<0 && imf(i,j+1)>0 && abs(imf(i,j-1)-imf(i,j+1))>2*S
                imout(i,j)=1;
            end
            if imf(i,j-1)>0 && imf(i,j+1)<0 && abs(imf(i,j-1)-imf(i,j+1))>2*S
                imout(i,j)=1;
            end
        end
    end
end