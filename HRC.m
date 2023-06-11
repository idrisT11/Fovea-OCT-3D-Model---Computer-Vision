% -------------------------------------------------------------------------
%
% Fonction qui détermine le HRC
%
% -------------------------------------------------------------------------

function vecteurInitialisation = HRC(image)

    I = rgb2gray(image);        % Conversion en niveau de gris

    L = size(I,2);              % Nombre de pixels par ligne
    seuilMoyPix = 30;           % Valeur moyenne des pixels d'une ligne pour qu'elle soit supprimée (pour les échantillons, 30 est le meilleur seuil)
    seuilSumLigne = L * seuilMoyPix;    % Critère de suppression d'une ligne

    PCH = profilCumule(I);              % Faire un profil cumulé
    vect = find(PCH >= seuilSumLigne);  % Regarder quelles lignes sont plus claires que le seuil

    I = I(min(vect) : max(vect),:);     % Conserver ces lignes
    [H2, L2] = size(I);     % nouvelles dimensions de l'image




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


    I = imgaussfilt(I, 2);                  % Filtrage par un noyau gaussien

    I = imclose(I, strel('disk', 5));       % Fermeture par un disque 5x5

    MAX = double(max(I(:)));                % Valeur maximale d'un pixel dans l'image

    % Augmentation des contrastes
    for x = 1:H2
        for y = 1:L2
            I(x,y) = round(double(I(x,y)) * (255/MAX));
        end
    end



    %% Contours bas par noyaux de Compass Gradient
    
    I_contour = padarray(I, [1 1], 'symmetric');    % Faire un bordage miroir
    imres = I;          % Faire une copie : imres = image où sera sauvegardée l'image résultat


    CG1 = double([1 1 1 ; -1 -2 1 ; -1 -1 1]);
    CG2 = double([1 1 1 ; 1 -2 1 ; -1 -1 -1]);
    CG3 = double([1 1 1 ; 1 -2 -1 ; 1 -1 -1]);



    for x = 1:H2
        for y = 1:L2
            im_sec = double(I_contour(x:x+2, y:y+2));
            R1 = im_sec .* CG1;
            res1 = sum(R1(:));
            R2 = im_sec .* CG2;
            res2 = sum(R2(:)); 
            R3 = im_sec .* CG3;
            res3 = sum(R3(:));
            pix = max([res1 res2 res3]);
            imres(x,y) = pix;
        end
    end


    seuil = 180;            % initialisation seuil image seuillée
    seuil_imres = 75;       % initialisation seuil image Compass gradient
    repartitionPoints = 0;
    
    while (repartitionPoints == 0)
        I_seuil = I >= seuil;               % Ne conserver que les pixels supérieurs au seuil (image fermée et puis contrastée)
        imres2 = imres > seuil_imres;       % Ne conserver que les pixels supérieurs au seuil (image de Compass gradient)

        % Chercher les pixels présents dans les 2 images
        for x = 1:H2
            for y = 1:L2
                if I_seuil(x,y) == 0       
                    imres2(x,y) = 0;
                end
            end
        end

        imres2 = imclose(imres2, strel('disk', 10));    % Fermeture par un disque de rayon 10


        %% Vérifier qu'on a des points assez bien répartis
        pourcentBouts = 15;
        pas = 20;
        IMAGE = imres2';        % Image transposée

        debut = round(size(IMAGE, 1) * pourcentBouts / 100);
        fin = round(size(IMAGE, 1) * (100-pourcentBouts) / 100);

        repartition = ones(round(size(IMAGE,1)));

        for colonne = debut:pas:fin
            section = IMAGE(colonne:colonne+pas,:);
            if (sum(section(:)) == 0)
                repartition(colonne:colonne+pas) = 0;
            end
        end
        if repartition ==  ones(round(size(IMAGE,1)))
            repartitionPoints = 1;
            disp("OK !");
        else 
            seuil = seuil - 5;
            seuil_imres = seuil_imres - 5;
            disp("Non !");
        end

    end    

    
    vecteurInitialisation = ones(length(debut:pas:fin),2);
    compteur = 1;
    for i = debut:pas:fin
        section = IMAGE(i : i + pas,:);
        PCH = profilCumule(section');
        abs = max(find(PCH > 0));
        line = section(:,abs);
        ord = min(find(line>0));
        vecteurInitialisation(compteur,:) = [abs ; ord+i];
        compteur = compteur +1;
    end


    imres2 = IMAGE';
    IMVECT = zeros(size(imres2));


    for z = 1:length(vecteurInitialisation)
        disp(vecteurInitialisation(z));
        abs = vecteurInitialisation(z, 1);
        ord = vecteurInitialisation(z, 2);
        IMVECT(abs, ord) = 1;
    end



    %% Effectuer un contour actif à partir des points initialisés
    



    figure(1);
    subplot(3,1,1);
    imshow(imres);
    subplot(3,1,2);
    imshow(IMVECT);
    subplot(3,1,3);
    imshow(imres2);









end






