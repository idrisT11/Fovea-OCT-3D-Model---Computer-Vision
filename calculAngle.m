% -------------------------------------------------------------------------
%
% Fonction qui calcule l'angle de la flèche
% La fonction revoie :
% - 
%
% -------------------------------------------------------------------------


function angle = calculAngle(im_globale)

    [H,L] = size(im_globale(:,:, 1));           % Hauteur, Largeur
    im_fleche = im_globale(:,:,2) >= 255;       % Uniquement les pixels dont la composante verte = 255



    %% Masquer les angles haut-gauche et bas-gauche

    % Les flèches de im_globale forment un cercle centré au centre de l'image. Les éléments à supprimer sont
    % hors de ce cercle.
    rayon = round(max(size(im_fleche))/2);       %  Rayon du cercle
    coteCarre = floor(rayon * (1-sqrt(2)/2));    % Largeur du côté du carré à effacer, arrondi à l'entier inférieur

    % Effacement des coins
    im_fleche(1:coteCarre, 1:coteCarre) = zeros(coteCarre, coteCarre);              % Suppression haut à gauche
    im_fleche(H-coteCarre + 1 : end, 1 : coteCarre) = zeros(coteCarre, coteCarre);  % Suppression en bas à gauche



    %% Déterminer les deux terminaisons de la flèche
    
    PCV = profilCumule(im_fleche);      % Profil cumulé vertical   
    PCH = profilCumule(im_fleche');     % Profil cumulé horizontal


    % Déterminer la position la pointe de la fleche
    abs_pointe = find(PCV == max(PCV), 1);     % Renvoie une seule abscisse
    ord_pointe = find(PCH == max(PCH), 1);     % Renvoie une seule ordonnee


    % Effacer la pointe de la flèche pour ne conserver que le trait (le trait a une épaisseur de 1)
    dLCN = 10;      % demi-largeur carré noir qui efface (flèche remplacée par un carré noir)
    im_fleche(abs_pointe - dLCN : abs_pointe + dLCN, ord_pointe - dLCN : ord_pointe + dLCN) = zeros(2*dLCN + 1, 2*dLCN + 1);



    % Trouver les deux extrémités du trait
    for x=1:H
        for y=1:L
            if im_fleche(x,y) == 1      % Le premier pixel blanc (en balayant par la gauche puis haut->bas) 
                pt1 = [x, y];           % Extrémité 1
                break
            end
        end
    end
    
    for x=1:H
        for y=1:L
            if im_fleche(H-x+1,L-y+1) == 1      % Le premier pixel (en balayant par la droite puis bas->haut)
                pt2 = [H-x+1, L-y+1];           % Extrémité 2
                break
            end
        end
    end



    %% Calculer l'angle
    x = (pt2(2) - pt1(2));          % Différence des abscisses (on s'arrange pour avoir x > 0) ; coordonnées Matlab -> coordonnées classiques
    y = (pt1(1) - pt2(1));          % Différence des ordonnées
   


    if x >= 0                       % Si x positif, arctan renvoie dans [-pi/2 ; pi/2] 
        angle = atan(y/x);          % Renvoyer l'angle

    else                            % Si x négatif, on veut un angle dans [-pi ; pi/2] U [pi/2 ; pi], mais arctan renverra un angle dans [-pi/2 ; pi/2]
        x = -x;                     % Inverser le sens du vecteur pour que arctan renvoie un angle dans le vrai intervalle
        y = -y;
        angle = atan(y/x) + pi;     % Ajouter pi pour trouver l'angle du vecteur dans son vrai sens 
        
    end



    %% Trouver le sens de la flèche (dans les calculs précédents, la trait va de pt1 vers pt2) 
    if ((pt1(1)-abs_pointe)^2 + (pt1(2)-ord_pointe)^2) <= ((pt2(1)-abs_pointe)^2 + (pt2(2)-ord_pointe)^2)
    % Si la flèche était en "pt1"
        angle = angle + pi;     % On ajoute pi pour inverser le sens et retrouver le bon angle 
    end

    % Renvoyer un angle dans l'intervalle [0 ; 2pi[
    angle = mod(angle, 2*pi);


    %% Affiche la valeur de l'angle en radian (intervalle [0 ; 2pi[)
%     fprintf("X=%d, Y=%d", x, y);
%     disp(" ");
%     disp(angle);



    %% Affiche les deux images : l'image ne comportant que le trait et l'image originale)
%     figure;
%     subplot(2,1,1);
%     imshow(im_fleche);
%     subplot(2,1,2);
%     imshow(im_globale);



end
