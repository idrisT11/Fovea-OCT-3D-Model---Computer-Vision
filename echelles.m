% -------------------------------------------------------------------------
%
% Fonction qui calcule la taille de chaque pixel (en mm)
% - Prend en argument une image (section ou plan)
% La fonction revoie :
% - Largeur d'un pixel (en m)
% - Hauteur d'un pixel (en m)
%
% -------------------------------------------------------------------------


function [ech_x, ech_y] = echelles(image)
    
    %% Constantes
    taille = 200E-9;        % Longueur (réelle) de chaque échelle (en m)
    largeurDecoupe = 70;    % Largeur du carré extrait en pixels
    H = size(image, 1);     % Hauteur de l'image
    

    %% Travailler sur l'échelle (en bas à gauche de l'image)
    decoupe = image(H-largeurDecoupe-1:end, 1:largeurDecoupe) == 255;   % Pixels blancs (255) dans le carré extrait


    %% Eroder l'image pour ne conserver que les deux échelles.
    % L'élément structurant est un carré de dimension 2x2 (les traits font 2 pixels d'épaisseur)
    S1 = [1 1 0; 1 1 0 ; 0 0 0];
    S2 = [0 1 1; 0 1 1 ; 0 0 0];
    S3 = [0 0 0; 1 1 0 ; 1 1 0];
    S4 = [0 0 0; 0 1 1 ; 0 1 1];
    decoupe = imerode(decoupe, S1) | imerode(decoupe, S2) | imerode(decoupe, S3) | imerode(decoupe, S4);


    %% Calculer la taille de chaque pixel selon l'axe
    X = find(profilCumule(decoupe)>=1);     % Répertorie les positions des pixels blancs (suivant x)
    Y = find(profilCumule(decoupe')>=1);    % Répertorie les positions des pixels blancs (suivant y)
    
    ech_x = taille / (X(length(X))-X(1)); % taille d'un pixel selon l'axe x (coordonnées Matlab)
    ech_y = taille / (Y(length(Y))-Y(1)); % taille d'un pixel selon l'axe y (coordonnées Matlab)


end
