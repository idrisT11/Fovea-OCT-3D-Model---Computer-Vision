% -------------------------------------------------------------------------
%
% Fonction qui détermine le HRC
%
% -------------------------------------------------------------------------

function vectInit  = extractHRC(image)

    %I = rgb2gray(image);        % Conversion en niveau de gris
    I = image;
    I = im2uint8(I);

    L = size(I,2);              % Nombre de pixels par ligne

    %% Etape 1 : conserver la partie contenant l'information utile
    seuilMoyPix = 30;      % Seuil valeur moyenne des pixels d'une ligne (expériementalement, 30 est une bonne valeur)
    seuilSumLigne = L * seuilMoyPix;    % Passage de valeur moyenne à somme

    PCH = profilCumule(I);              % Faire un profil cumulé horizontal
    vect = find(PCH >= seuilSumLigne);  % Indice des lignes plus claires que le seuil
    limHaut = min(vect);        % limite haute de l'information utile
    limBas = max(vect);         % limite basse de l'information utile

    I = I(limHaut : limBas,:);  % conservation des lignes utiles 
    H = size(I,1);              % Nombre de lignes dans la nouvelle image




    %% Faire un filtrage dans l'espace
%     I_copy = padarray(I, [1 1], 'symmetric');       % Copie de matrice : bordage mirroir
%     kernel = [0 1 0; 1 1 1; 0 1 0];     % Noyau de connexité 4
%     kernel = double(kernel / sum(kernel(:)));
% 
% 
%     % Filtrage par le noyau précédent
%     for x = 1:H2
%         for y = 1:L2
%             I_sec = double(I_copy(x:x+2, y:y+2));       % Section d'image
%             res = I_sec .* kernel;              % Multiplication terme à terme des coefficients
%             pix = sum(res(:));                  % Faire la somme des résultats
%             pix = round((pix - seuilMoyPix*2) * 255 / (255 - seuilMoyPix*2));   % Augmentation des contrastes 
%             I(x,y) = pix;       % Donner au pixel sa nouvelle valeur
%         end
%     end

    
    %% Etape 2 : traiter l'image obtenue
    I = imgaussfilt(I, 2);              % Filtrage par un noyau gaussien pour supprimer le bruit
    I = imclose(I, strel('disk', 5));   % Fermeture par un disque 5x5 pour mieux marquer la ligne blanche en supprimant les petites composantes sombres
    fact = 255 / double(max(I(:)));     % Facteur de multiplication pour augmenter le contraste


    % Augmentation des contrastes
    for x = 1:H
        for y = 1:L
            I(x,y) = round(double(I(x,y)) * fact);      % Multiplie la valeur des pixels par fact
        end
    end



    %% Etape 3 : Multiplier l'image par des filtres directionnels Compass Gradient
    
    IBord = padarray(I, [1 1], 'symmetric');       % Faire un bordage miroir de l'image I
    imContour = I;          % Image résultat


    % Définir les noyaux utilisés : seulement les noyaux de contour vers le bas
    CG1 = double([1 1 1 ; -1 -2 1 ; -1 -1 1]);      % Compass Gradient bas-gauche
    CG2 = double([1 1 1 ; 1 -2 1 ; -1 -1 -1]);      % Compass Gradient bas-centre
    CG3 = double([1 1 1 ; 1 -2 -1 ; 1 -1 -1]);      % Compass Gradient bas-droite


    % Calculer la réponse de l'image par chaque filtre
    for x = 2:H+1
        for y = 2:L+1
            im_sec = double(IBord(x-1:x+1, y-1:y+1));      % Voisinage du pixel étudié
            R1 = im_sec .* CG1;         % Multiplication point à point avec le filtre bas-gauche
            res1 = sum(R1(:));          % Calculer la réponse avec le filtre bas-gauche
            R2 = im_sec .* CG2;         % Multiplication point à point avec le filtre bas-centre
            res2 = sum(R2(:));          % Calculer la réponse avec le filtre bas-centre
            R3 = im_sec .* CG3;         % Multiplication point à point avec le filtre bas-droit
            res3 = sum(R3(:));          % Calculer la réponse avec le filtre bas-droit
            pix = max([res1 res2 res3]);    % Conserver la réponse maximale
            imContour(x-1,y-1) = pix;      % Attribuer au pixel sa nouvelle valeur
        end
    end




    %% Combiner l'image de contours avec l'image ayant subi des fermetures
    seuil = 200;            % initialisation seuil image fermée
    seuilContour = 100;      % initialisation seuil image Compass Gradient
    
    repartitionPoints = 0;  % initialisation booléen condition d'arrêt boucle while
    

    %% Itérer tant qu'on n'obtient pas assez de points pour tracer le coutour bas du HRC
    while (repartitionPoints == 0)
        imSeuil = I >= seuil;               % Ne conserver que les pixels supérieurs au seuil (image fermée et puis contrastée)
        imres = imContour > seuilContour;   % Ne conserver que les pixels supérieurs au seuil (image de Compass gradient)

        % Chercher les pixels présents dans les 2 images
        for x = 1:H
            for y = 1:L
                if imSeuil(x,y) == 0        % Si absent de l'image seuillée
                    imres(x,y) = 0;         % Le pixel de l'image 
                end
            end
        end

        imres = imclose(imres, strel('disk', 10));    % Fermeture par un disque de rayon 10


        %% Définir des fenêtres dans lesquelles on regarde si on a trouvé au moins 1 point
        pourcentBouts = 15;     % On ne s'intéresse pas à toute l'image (sur les bords, il n'y a pas forcément de contour)
        pas = 20;               % Pas d'échantillonnage : correspond à la distance max entre 2 points

        debut = round(size(imres, 2) * pourcentBouts / 100);        % Debut de balayage
        fin = round(size(imres, 2) * (100-pourcentBouts) / 100);    % Fin de balayage

        fenetreNoire = 0;            % Initialisation booléen fenetre noire

        for i = debut:pas:fin
            im_sec = imres(:, i : i+pas);   % Fenêtre de recherche
            if sum(im_sec(:)) == 0          % Si une fenêtre est complètement noire
                fenetreNoire = 1;           % On l'enregistre dans le booléen 
                break;
            end
        end
        
        if fenetreNoire == 1                % Si une fenêtre ne comporte aucun point
            repartitionPoints = 0;          % On recommence la boucle
            seuil = seuil - 3;              % On réduit les seuils de la valeur du pixel de l'image
            seuilContour = seuilContour-5;  % On réduit le seuil de la valeur du contour recherché
        else                                % S'il y a au moins un point par fenêtre
            repartitionPoints = 1;          % On sort de la boucle
        end

    end    

    
    %% Récupérer les points du contour bas du HRC
    vectInit = ones(length(debut:pas:fin),2);   % Vecteur des points de contour (taille : nombre de fenêtres x 2)
    compteur = 1;                               % Compteur pour insérer les valeurs dans le vecteur 
    for i = debut:pas:fin
        im_sec = imres(: , i : i+pas);          % On sélectionne la fenêtre
        increment = 0;                          % Initialisation incrément (on remonte les lignes)
        while sum(im_sec(H-increment, :)) == 0  % Tant que la ligne est blanche
            increment = increment + 1;          % On incrémente
        end
        abscisse = H - increment;               % Définir l'abscisse de la ligne non-noire
        ordonnee = find(im_sec(abscisse,:) == 1, 1, "first");   % Trouver l'ordonnée du premier élément blanc de la ligne
        
        vectInit(compteur, :) = [abscisse + limHaut - 1 ; ordonnee+i];   % Ajouter le point à vectInit (points dans les coordonnées de l'image d'origine)
        compteur = compteur +1;                 % Incrémenter le compteur
    end

    

    %% Supprimer les erreurs et régulariser le contour
    % vectInitModif = zeros(size(vectInit));  % vecteur modifié
    for i=2:length(vectInit)-1
        ptAv = [vectInit(i-1, 1) ; vectInit(i-1, 2)];       % Point précédent
        pt   = [vectInit(i  , 1) ; vectInit(i  , 2)];       % Point d'étude
        ptAp = [vectInit(i+1, 1) ; vectInit(i+1, 2)];       % Point suivant
        % Objectif : si les points précédents et suivants sont plus proches
        % que le point d'étude avec ces deux autres points, alors on
        % considère qu'il s'agit d'une fausse détection. On replace ce
        % point entre les 2.
        distAvAp = sqrt((ptAv(1) - ptAp(1))^2 + (ptAv(2) - ptAp(2))^2);     % Distance
        distptAv = sqrt((ptAv(1) - pt(1))^2 + (ptAv(2) - pt(2))^2);
        distptAp = sqrt((ptAp(1) - pt(1))^2 + (ptAp(2) - pt(2))^2);
        if distAvAp < distptAp && distAvAp < distptAv   % Si le point est très éloigné de la courbe
            % fprintf("P_initial : %d       %d\n", pt(1), pt(2));
            % fprintf("P_av : %d       %d\n", ptAv(1), ptAv(2));
            % fprintf("P_ap : %d       %d\n", ptAp(1), ptAp(2));
            pente = (ptAp(1) - ptAv(1)) / (ptAp(2) - ptAv(2));
            % fprintf("Pente : %d\n", pente);
            newAbs = ptAv(1) + (pt(2) - ptAv(2)) * pente;
            vectInit(i,1) = round(newAbs); 
            % fprintf("P_final : %d       %d\n", vectInit(i,1), vectInit(i,2));
            % disp(" ");

        end
    end



    %% Représenter ces points sur une image

    im_vect = zeros(size(image));           % Image qui représente les points affichés

    for x = 1:length(vectInit)              % On parcourt le vecteur de points
        abscissa = vectInit(x, 1);          % Abscisse du point du vecteur
        ordonnee = vectInit(x, 2);          % Ordonnee du point du vecteur
        im_vect(abscissa, ordonnee) = 1;    % On ajoute les points sur l'image
    end


    vectInit = vectInit';

end






