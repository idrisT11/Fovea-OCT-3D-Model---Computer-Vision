% -------------------------------------------------------------------------
%
% Fonction qui sépare les deux parties intéressantes d'une image .png
% La fonction revoie :
% - La coupe de rétine (image de droite) : im_coupe
% - L'image large de la rétine (vue de dessus - image de gauche) : im_globale
%
% -------------------------------------------------------------------------


function [im_coupe, im_globale] = separationImages(image)
    

    %% Etape 1 : tranformer l'image en image en niveaux de gris
    im = rgb2gray(image);       % Transforme l'image en image en niveaux de gris (supprime la composante verte)
    [H, L] = size(im);          % Dimensions de l'image en pixels (Hauteur et Largeur)



    %% Etape 2 : calculer le profil cumulé horizontal pour extraire les images
    PCH = profilCumule(im);           % Profil Cumulé Horizontal    



    %% Etape 3 : Trouver la plus longue séquence de lignes non-noires (valeur > 0)
    valMoyMin = 0;                  % Valeur seuil (valeur moyenne du pixel sur une ligne pour la considérer non-noire)
    PCH = PCH > valMoyMin;          % Prennent 1 toutes les lignes dont la valeur moyenne du pixel est supérieure au seuil

    % On recherche la plus longue sous-séquence supérieure au seuil
    maxLongueur = 0;    % initialisation de la valeur de la longueur maximale d'une séquence de "1" trouvée
    PCH = [0 PCH];      % On rajoute un 0 en début pour s'assurer qu'on ait un passage de 0 à 1
    
    i=1;                % Initialisation incrément boucle while
    while i<H+1         % On va jusqu'à H+1 car on a ajouté un élément (il y a H+1 éléments dans le vecteur)
        
        %% Si passage de 0 à 1
        if PCH(i) < PCH(i+1)    % Si PCH(i-1) == 0 et PCH(i) == 1
            % Rq : la transition s'effectue à i+1, mais on a rajouté un
            % élément en début de vecteur, donc au niveau de la liste
            % originale, elle s'effectue en i
            
            %% On regarde la longueur du plateau
            k = 1;
            while PCH(i + k) == 1       % On cherche le 1er élément égal à 0
                k = k+1;
            end


            %% Si la longueur du plateau est plus grande que celle maximale enregistrée, on met à jour les valeurs
            if k > maxLongueur
                debut = i;              % Début du plateau
                maxLongueur = k;        % Longueur du plateau (indique par conséquent aussi la fin du plateau
            end
            i = i + k;      % On reprend à la fin du plateau trouvé
        end
        i = i+1;    % Incrémentation
    end
    

    limiteHorizontale = debut + maxLongueur - 1;

    deuxImages = im(debut: limiteHorizontale, :);      % Image obtenue après découpe du bandeau inférieur 

   


%% Séparer les 2 images restantes
    deuxImages = deuxImages';   % Transposer l'image pour déterminer le profil cumulé des colonnes

    PCV = profilCumule(deuxImages);           % Profil Cumulé Vertical

    PCV = PCV - [0 PCV(1:end-1)];      % Dérivée discrète d'ordre 1 (utilisée pour l'étude des variations du profil cumulé)

    limiteVerticale = find(PCV == min(PCV));         % Séparation entre les deux images, se retranscrit par une rupture nette sur le profil cumulé
   


    % Découper l'image d'origine (en couleurs RGB)
    im_globale = image(debut : limiteHorizontale, 1:limiteVerticale, :);
    im_coupe = image(debut : limiteHorizontale, limiteVerticale+1 : end, :);


%     figure;
%     subplot(2,2,[1 2]);
%     imshow(image);
%     title("image");
% 
%     subplot(2,2,3);
%     imshow(im_globale);
%     title("im\_globale");
% 
%     subplot(2,2,4);
%     imshow(im_coupe);
%     title("im\_coupe");

end