% img : module du gradient
% imdir : argument du gradient

%ici on aminci l'image

function imres = suppressNonMaxima(img, imdir)


[H,W] = size(img);

% 4 images, une par direction (0,45,90,135)
im1=  abs(imdir)<=pi/8 ;
im2=  imdir>pi/8 & imdir<=3*pi/8;
im3=  abs(imdir) > 3*pi/8 & abs(imdir) <=pi/2;
im4=  imdir < 0 & abs(imdir) > pi/8 & abs(imdir)<= 3*pi/8;



%% Supprimer les valeurs qui ne sont pas des maxima locaux
imres = zeros(H,W);
for i=2:H-1
    for j=2:W-1
        if im1(i,j)>0 && (img(i-1,j)<img(i,j) && img(i+1,j)<=img(i,j) )
            imres(i,j) = img(i,j);
        elseif im2(i,j)>0 && (img(i-1,j-1)<img(i,j) && img(i+1,j+1)<=img(i,j) )
            imres(i,j) = img(i,j);
        elseif im3(i,j)>0 && (img(i,j-1)<img(i,j) && img(i,j+1)<=img(i,j) )
            imres(i,j) = img(i,j);
        elseif im4(i,j)>0 && (img(i+1,j-1)<img(i,j) && img(i-1,j+1)<=img(i,j) )
            imres(i,j) = img(i,j);
        end
    end
end