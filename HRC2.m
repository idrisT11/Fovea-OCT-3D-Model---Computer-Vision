% -------------------------------------------------------------------------
%
% Fonction qui détermine le HRC
%
% -------------------------------------------------------------------------

function [VectHRCBas, VectHRCHaut] = HRC(image)

    image = rgb2gray(image);    % Conversion de l'image en niveaux de gris
    image_gray = image;         % Copie d'une version de cette image (utilisée dans les contours actifs)

    L = size(image,2);          % Largeur de l'image 



    
  %% Etape 1 : conserver la partie de l'image contenant l'information utile
    
    % On trace un profil cumulé et on ne conserve que les lignes ayant les
    % pixels les plus prononcés
    seuilMoyPix = mean(image(:));       % Seuil valeur moyenne des pixels d'une ligne, défini comme la moyenne de l'image
    seuilSumLigne = L * seuilMoyPix;    % Passage de valeur moyenne à somme (simplifie les calculs)

    % Calcul du profil cumulé horizontal
    PCH = profilCumule(image);              % Calcule le profil cumulé horizontal
    vect = find(PCH >= seuilSumLigne);      % Récupère les indice des lignes plus claires que le seuil
    limHaut = min(vect);        % Première ligne supérieure au seuil
    limBas = max(vect);         % Dernière ligne supérieure au seuil
    % Remarque : l'échelle en bas à gauche n'est pas assez épaisse pour que
    % ces lignes dépassent le seuil (valeur moyenne d'une image : entre 30
    % et 45 - expérimentalement)

    image = image(limHaut : limBas,:);      % On ne conserve que les lignes dites "utiles" 
    H = size(image,1);                      % Nombre de lignes dans la nouvelle image (Hauteur) ; Largeur inchangée


    %% Etape 2 : Traiter l'image
    
    I_open = imopen(image, ones(5,5));      % Effectuer une ouverture par un carré 5x5

    
    %% Etape 2-1 : éliminer les pixels clairs de la limitante interne
    I = imopen(image, ones(5,1));           % Effectuer une ouverture par un vecteur 5x1 (le HRC est beaucoup plus épais que les pixels clairs du ILM)


    I_contour = padarray(I, [1 1], 'symmetric');    % Effectuer un bordage miroir (utilisé par la suite pour un filtrage)
 

    %% Etape 2-2 : Augmenter le contraste
    seuil_bas = 170;                                % On ne garde que les points supérieurs au seuil
    for x=1:H
        for y=1:L
            newVal = double(I(x,y) - seuil_bas) * double(255 / (255 - seuil_bas));  % Etendre sur la plage (seuil - 255)  
            I(x,y) = max(0, newVal);                % Mettre à 0 les valeurs négatives
        end
    end

  


    I = imclose(I, ones(3,15));     % Fermeture pour relier les points entre eux (dans le sens horizontal, puisque le HRC s'étend sur l'horizontale)

 

    I_res22 = I;                    % Copier le résultat 2-2



    %% Etape 2-3 : Filtrer avec un noyau réhausseur de contours ; on utilise I_contour (défini précédemment)

    SE = [0 0 0 ; -1 12 -1 ; -3 -3 -3];     % Noyau qui réhausse les contours bas

    for x=1:H
        for y=1:L
            mult = SE .* double(I_contour(x : x+2, y:y+2)); % Multiplier point à point le noyau et les pixels du voisinage
            I(x,y) = sum(mult(:));                          % Affecter au pixel le résultat
        end
    end

    I_filtre = I;           % Copier le résultat

 
    %% Etape 2-4 : recalibrer les résultats, supprimer les petites structures, connecter les plus grosses


    I_filtre = imopen(I_filtre, ones(3,3));       % Ouverture pour supprimer les petites structures
    I_filtre = imclose(I_filtre, ones(15,15));    % Fermeture pour relier les structures conservées
    

    
    %% Etape 3 : Segmenter l'image
    
    
    %% Etape 3-1 : Définir des seuils pour chaque image
    
    seuilIM1 = 175;             % Valeur minimale d'un pixel de I_open
    seuilIM2 = 50;              % Valeur minimale d'un pixel de I_res22
    seuilIM3 = 225;             % Valeur minimale d'un pixel de I
       
    
    IM1 = I_open >= seuilIM1;   % Seuillage n°1 : les pixels sont suffisamment clairs
    IM2 = I_res22 >= seuilIM2;  % Seuillage n°2 : les pixels font partie de la bande claire
    IM3 = I_filtre >= seuilIM3; % Seuillage n°3 : les pixels font partie des zones contrastées (après ouverture + fermeture)


    I_finale = IM1 + IM2 + IM3 >= 2;  % Comme les seuils sont stricts, on considère qu'on en accepte 2/3 au moins


    %% Affichage des figures
%     figure(1);
%     subplot(4,1,1);
%     imshow(IM3);
%     subplot(4,1,2);
%     imshow(IM2);
%     subplot(4,1,3);
%     imshow(IM1);
%     subplot(4,1,4);
%     imshow(I_finale);
    


    %% Echantillonner l'image segmentée pour récupérer les positions des points
    nbPtsInit = 30;                 % Nombre de points à extraire
    pas = floor(L / nbPtsInit);     % Pas
    largeur = nbPtsInit * pas;      % Largeur de l'étude (on supprimera de part et d'autre les bords
    debut = floor((L - largeur) / 2);   % Limite gauche de la recherche
    fin = debut + largeur;              % Limite droite de la recherche 
    vectInit = zeros(nbPtsInit, 2);     % Vecteur contenant les positions des points : dimensions nbPtsInit x 2
                          

    %% Pour chaque fenêtre, prendre le points le plus bas
    compteur = 0;               % Numéro de la fenêtre
    for i = debut:pas:fin-pas   % On parcours nbPtsInit fois la boucle
        compteur = compteur + 1;            % Incrémenter le compteur 
        fenetre = I_finale(:, i:i+pas-1);   % Construire la fenêtre de recherche
        % =================================================================
        if sum(fenetre(:)) >= 1         % Si au moins 1 pixel blanc dans la fenêtre (on peut trouver le points)
            increment = 0;              % On cherche le points ; on parcours les lignes par le bas
            while sum(fenetre(H-increment, :)) == 0     % Tant que la ligne est noire,
                increment = increment + 1;              % On regarde la ligne du dessus
            end
            % Quand on a trouvé la ligne désirée
            abscisse = H - increment;               % On relève le numéro de la ligne
            ordonnee = find(fenetre(abscisse, :) == 1, 1, 'first');     % On cherche le premier élément non-nul
            vectInit(compteur,1) = abscisse + limHaut -1;       % On ajoute l'abscisse à vectInit, !! Par rapport à l'image d'origine, on doit tenir compte de la section supprimée !!
            vectInit(compteur,2) = ordonnee + i;    % On ajoute l'ordonnée,
        % =================================================================
        else                            % Si fenêtre noire ; il faut réduire les seuils
            seuilAAugmenter = 0;        % On va venir augmenter les seuils à tour de rôle
            % Enregistrer les valeurs des seuils, pour ne pas modifier les
            % valeurs initiales (sinon, ça peut provoquer des erreurs
            % durant les autres passages dans la boucle)
            S1 = seuilIM1;          % Copie seuilIM1
            S2 = seuilIM2;          % Copie seuilIM2
            S3 = seuilIM3;          % Copie seuilIM3
            % Fenêtrer les trois images en niveaux de gris
            f1 = I_open(:, i:i+pas-1);      % Fenêtrage de l'image I_open
            f2 = I_res22(:, i:i+pas-1);     % Fenêtrage de l'image I_res22
            f3 = I_filtre(:, i:i+pas-1);    % Fenêtrage de l'image I_filtre
            bool1 = f1 >= S1;       % Appliquer les seuils
            bool2 = f2 >= S2;
            bool3 = f3 >= S3;
            while bool1 + bool2 + bool3 < 2     % Tant qu'on ne trouve pas de pixel qui respecte 2 des 3 règles
                sAug = mod(seuilAAugmenter, 3); % On diminue un seuil parmis les 3
                
                if sAug == 0                    % On commence par diminuer le seuilIM1
                    S1 = max(0, S1 - 5);        % -5 semble être une bonne valeur
                    bool1 = f1 >= S1;           % On réffectue un seuillage

                elseif sAug == 1                % On diminue ensuite le seuilIM2
                    S2 = max(0, S2 - 3);        % -3
                    bool2 = f2 >= S2;           % Seuillage

                else                            % On diminue seuilIM3
                    S3 = max(0,S3 - 5);         % -5
                    bool3 = f3 >= S3;           % Seuillage
                end
                seuilAAugmenter = seuilAAugmenter + 1;  % On passe au seuil suivant
            end
            seuilIM1 = S1;              % On récupère les valeurs de chaque seuil       
            seuilIM2 = S2;  
            seuilIM3 = S3;
            f1 = f1 >= seuilIM1;        % On effectue les seuillages (on obtient des images binaires)
            f2 = f2 >= seuilIM2;
            f3 = f3 >= seuilIM3;
            fenetre = f1 + f2 + f3 >= 2;      % On conserve les pixels vérifiants 2 propriétés
            
            % A présent, on recherche la position du(des) pixel(s) blanc(s) 
            increment = 0;
            while sum(fenetre(H-increment, :)) == 0
                increment = increment + 1;
            end
            abscisse = H - increment;
            ordonnee = find(fenetre(abscisse, :) == 1, 1, 'first');
            vectInit(compteur,1) = abscisse + limHaut + 1;
            vectInit(compteur,2) = ordonnee + i;
        end
    end




%% Supprimer les erreurs et régulariser le contour
    for i=2:length(vectInit)-1          % Etudier tous les points, saufs les bords
        ptPR = [vectInit(i-1, 1) ; vectInit(i-1, 2)];       % Point précédent
        pt   = [vectInit(i  , 1) ; vectInit(i  , 2)];       % Point d'étude
        ptSU = [vectInit(i+1, 1) ; vectInit(i+1, 2)];       % Point suivant
        %% Cas 1 : ce point est très éloigné de la courbe
        % Objectif : si les points précédents et suivants sont plus proches
        % l'un de l'autre que du point d'étude, alors on considère qu'il 
        % s'agit d'une fausse détection. On projete ce point sur l'axe formé
        % par les deux autres.
        distPRSU = sqrt((ptPR(1) - ptSU(1))^2 + (ptPR(2) - ptSU(2))^2);     % Distance entre le point précédent et le suivant
        distptPR = sqrt((ptPR(1) - pt(1))^2 + (ptPR(2) - pt(2))^2);         % Distance avec le point précédent
        distptSU = sqrt((ptSU(1) - pt(1))^2 + (ptSU(2) - pt(2))^2);         % Distance avec le point suivant
        if (distPRSU < distptSU && distPRSU < distptPR)  % Si le point est très éloigné de la courbe
            pente = (ptSU(1) - ptPR(1)) / (ptSU(2) - ptPR(2));  % Pente entre le point précédent et le suivant
            newAbs = ptPR(1) + (ptSU(2) - pt(2)) * pente;       % Projeter ce point sur l'axe
            vectInit(i,1) = round(newAbs);          % Enregistrer la nouvelle valeur d'abscisse
        end
        
        %% Cas 2 : si on a un changement brut de la pente
        penteSU = (ptSU(1) - pt(1)) / (ptSU(2) - pt(2));    % Pente avec le point suivant
        pentePR = (pt(1) - ptPR(1)) / (pt(2) - ptPR(2));    % Pente avec le point précédent
        if (abs(penteSU)) >= 0.5 && abs(pentePR/penteSU) <= 0.1     % Si on a une pente supérieur à 0.5 et penteSU > 10 pentePR
            newAbs = pt(1) + (ptSU(2) - pt(2)) * pentePR;   % On calcule la nouvelle abscisse par projetion du point sur l'axe (PR - pt)
            vectInit(i+1,1) = round(newAbs);                % On modifie la valeur du point
        end

        %% Cas 3 : point nettement décalé
        seuilDecalage = 20;
        if abs(ptSU(1)-pt(1)) >= seuilDecalage      % Si le point est nettement décalé 
            pentePR = (ptSU(1) - pt(1)) / (ptSU(2) - pt(2));    % Pente avec le point précédent
            newAbs = pt(1) + (ptSU(2) - pt(2)) * pentePR;   % On calcule la nouvelle abscisse par projetion du point sur l'axe (PR - pt)
            vectInit(i+1,1) = round(newAbs);                % On modifie la valeur du point
        end
    end


    %% Cas 4 : pour les bornes gauche et droite
    % Borne gauche
    pt1 = [vectInit(1, 1) ; vectInit(1, 2)];       % Premier point
    pt2 = [vectInit(2, 1) ; vectInit(2, 2)];       % Deuxième point 
    pt3 = [vectInit(3, 1) ; vectInit(3, 2)];       % Troisième point
    pente23 = (pt3(1) - pt2(1)) / (pt3(2) - pt2(2));
    newAbs = pt2(1) - (pt2(2) - pt1(2)) * pente23;
    vectInit(1,1) = round(newAbs);


    % Borne droite
    fin = size(vectInit,1);                         % Nombre de points dans le vecteur
    ptd1 = [vectInit(fin-2, 1) ; vectInit(fin-2, 2)];   % Premier point
    ptd2 = [vectInit(fin-1, 1) ; vectInit(fin-1, 2)];   % Deuxième point 
    ptd3 = [vectInit(fin  , 1) ; vectInit(fin  , 2)];   % Troisième point
    pente12 = (ptd2(1) - ptd1(1)) / (ptd2(2) - ptd1(2));
    newAbs = ptd2(1) + (ptd3(2) - ptd2(2)) * pente12;
    vectInit(fin,1) = round(newAbs);


    %% Lisser une seconde fois

    for i=2:length(vectInit)-1          % Etudier tous les points, saufs les bords
        ptPR = [vectInit(i-1, 1) ; vectInit(i-1, 2)];       % Point précédent
        pt   = [vectInit(i  , 1) ; vectInit(i  , 2)];       % Point d'étude
        ptSU = [vectInit(i+1, 1) ; vectInit(i+1, 2)];       % Point suivant
        %% Cas 1 : ce point est très éloigné de la courbe
        % Objectif : si les points précédents et suivants sont plus proches
        % l'un de l'autre que du point d'étude, alors on considère qu'il 
        % s'agit d'une fausse détection. On projete ce point sur l'axe formé
        % par les deux autres.
        distPRSU = sqrt((ptPR(1) - ptSU(1))^2 + (ptPR(2) - ptSU(2))^2);     % Distance entre le point précédent et le suivant
        distptPR = sqrt((ptPR(1) - pt(1))^2 + (ptPR(2) - pt(2))^2);         % Distance avec le point précédent
        distptSU = sqrt((ptSU(1) - pt(1))^2 + (ptSU(2) - pt(2))^2);         % Distance avec le point suivant
        if (distPRSU < distptSU && distPRSU < distptPR)  % Si le point est très éloigné de la courbe
            pente = (ptSU(1) - ptPR(1)) / (ptSU(2) - ptPR(2));  % Pente entre le point précédent et le suivant
            newAbs = ptPR(1) + (ptSU(2) - pt(2)) * pente;       % Projeter ce point sur l'axe
            vectInit(i,1) = round(newAbs);          % Enregistrer la nouvelle valeur d'abscisse
        end
        
        %% Cas 2 : si on a un changement brut de la pente
        penteSU = (ptSU(1) - pt(1)) / (ptSU(2) - pt(2));    % Pente avec le point suivant
        pentePR = (pt(1) - ptPR(1)) / (pt(2) - ptPR(2));    % Pente avec le point précédent
        if (abs(penteSU)) >= 0.5 && abs(pentePR/penteSU) <= 0.2     % Si on a une pente supérieur à 0.5 et penteSU > 10 pentePR
            newAbs = pt(1) + (ptSU(2) - pt(2)) * pentePR;   % On calcule la nouvelle abscisse par projetion du point sur l'axe (PR - pt)
            vectInit(i+1,1) = round(newAbs);                % On modifie la valeur du point
        end

        %% Cas 3 : point nettement décalé
        seuilDecalage = 20;
        if abs(ptSU(1)-pt(1)) >= seuilDecalage      % Si le point est nettement décalé 
            pentePR = (ptSU(1) - pt(1)) / (ptSU(2) - pt(2));    % Pente avec le point précédent
            newAbs = pt(1) + (ptSU(2) - pt(2)) * pentePR;   % On calcule la nouvelle abscisse par projetion du point sur l'axe (PR - pt)
            vectInit(i+1,1) = round(newAbs);                % On modifie la valeur du point
        end
    end


    

    %% Représenter ces points sur une image

    im_vect = zeros(size(image_gray));      % Image qui représente les points affichés

    for x = 1:length(vectInit)              % On parcourt le vecteur de points
        abscisse = vectInit(x, 1);          % Abscisse du point du vecteur
        ordonnee = vectInit(x, 2);          % Ordonnee du point du vecteur
        im_vect(abscisse, ordonnee) = 1;    % On ajoute les points sur l'image
    end


    im_vect = imdilate(im_vect, strel('disk', 2));


    




    %% Appliquer un contour actif à partir des points initialisés
    
    epaisseurHRC = 20;
    offset = 2;       % Augmenter la position de tous les points du vecteur, pour qu'il soit initialisé sur la bande blanche

    Vect1Bas = vectInit;
    Vect1Haut = vectInit;

    for x=1:length(vectInit)
        Vect1Haut(x,1) = Vect1Haut(x,1) - epaisseurHRC;      % initialiser le contour haut par un offset de +30 pixels
        Vect1Bas(x,1) = Vect1Bas(x,1) - offset;              % Initialiser le contour bas par un offset de +3 pixels
    end


    rep = cd;
    addpath([rep filesep 'SnakeKass']);
    addpath([rep filesep 'SnakeKass' filesep 'PS-MAIN']);
    addpath([rep filesep 'SnakeKass' filesep 'PS-SNAKES SAMPLING']);
    addpath([rep filesep 'SnakeKass' filesep 'PS-MATRIX']);
    addpath([rep filesep 'SnakeKass' filesep 'PS-SNAKES GVF COMMON']);



    %% GVF - see GVFCompute for parameters
    mode            = 1;            % 1 for edge, 2 for image, 3 for negative of image
    mu              = 0.3;
    nbGVFiter       = 10;
    sigma           = 5;        % Ecart-type


    H = size(image_gray, 1);
    image_gray(H-99:end, 1:100) = zeros(100, 100);      % Masquer la partie en bas à gauche (échelle)


    %% Augmenter le contraste
    maxi = max(image_gray(:));
    for x = 1:H
        for y = 1:L
            image_gray(x,y) = image_gray(x,y) * double(255 / maxi);
        end
    end

    seuil = seuilIM1;       % Reprendre le seuil donné précédemment

    [px,py, imEdgeMap] = GVFCompute(image_gray >= seuil, mode, mu, nbGVFiter,sigma);


%     figure(2); imshow(imEdgeMap); hold on;
%     [H,W] = size(I);
%     step = 3;
%     [Y,X] = meshgrid(1:step:W,1:step:H);
%     hold on;
%     quiver(Y,X,px(1:step:H,1:step:W),py(1:step:H,1:step:W));
    



    %%  Apply snake

    % define parameters 
    alpha       = 50;       % Alpha élevé 
    beta        = 50; 
    gamma       = 3;
    kappa       = 1;
    nbiter      = 50;       % 50 itérations fixées
    stepIter    = 5;
    maxChange   = 0.3;
    



    %% Pour le contour bas
    % fid = figure('Name','SNAKES'); 

    Xbas = Vect1Bas(:,1);
    Ybas = Vect1Bas(:,2);

    % Apply snake
    [Ybas,Xbas] = GVFSnake(image_gray,px,py,Ybas,Xbas, alpha,beta,gamma,kappa,nbiter,stepIter,maxChange);

    VectHRCBas = [Xbas';Ybas'];

    figure(1);
    hold off;
    imshow(image_gray);
    hold on
    plot(VectHRCBas(2,:),VectHRCBas(1,:),'r');


    
    %% Pour le contour haut

    % fid = figure('Name','SNAKES'); 

    Xhaut = Vect1Haut(:,1);
    Yhaut = Vect1Haut(:,2);

    % Apply snake
    [Yhaut,Xhaut] = GVFSnake(image_gray,px,py,Yhaut,Xhaut, alpha,beta,gamma,kappa,nbiter,stepIter,maxChange);

    VectHRCHaut = [Xhaut';Yhaut'];

    figure(1);
    hold off;
    imshow(image_gray);
    hold on
    plot(VectHRCBas(2,:),VectHRCBas(1,:),'r');
    plot(VectHRCHaut(2,:),VectHRCHaut(1,:),'g');

    pause(10);
end






