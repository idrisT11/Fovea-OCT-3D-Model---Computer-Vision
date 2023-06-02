% -------------------------------------------------------------------------
%
%   Florence ROSSANT - SITe
%
%   Seuillage par hysteresis d'une image de gradient
%
%   Entrées :
%       img     : image du module du gradient
%
%   Sortie :
%       imc     : image binaire du contour du gradient
%
%
% -------------------------------------------------------------------------

function imc = SeuillageHysteresis(img)


[H,W] = size(img);


%% Déterminer les seuils d'intensité

% Déterminer le seuil bas comprenant tous les points de contour recherchés
id = figure; subplot(2,2,1);title 'Module du gradient'
imshow(img);
seuilBas = input('Entrer le seuil bas : (<1)');
while seuilBas<1 
    im1 = img>=seuilBas;
    subplot(2,2,2);imshow(im1);title 'Image seuil bas';
    title (sprintf('Seuil Bas = %2.2f',seuilBas));
    figure(id);
    seuilOK = seuilBas;
    seuilBas = input('Entrer le seuil bas : (1 pour terminer)');
end
seuilBas = seuilOK;
    
% Déterminer le seuil bas comprenant que des points de contour recherchés
seuilHaut = input('Entrer le seuil haut (>0): ');
while seuilHaut>0 
    im2 = img>=seuilHaut;
    subplot(2,2,3);imshow(im2);title 'Image seuil haut';
    title (sprintf('Seuil Haut = %2.2f',seuilHaut));
    figure(id);
    seuilOK = seuilHaut;
    seuilHaut = input('Entrer le seuil haut : (0 pour terminer)');
end
seuilHaut = seuilOK;
    

%T = greythresh(img);
%seuilBas = T - 0.1;
%seuilHaut= T + 0.1;

%ordre seuil bas: 0.10 | seuil haut: 0.20

%% Seuiller avec ces seuils 

im1 = img >= seuilBas;     % Seuillage avec seuil bas
im2 = img >= seuilHaut;     % Seuillage avec seuil haut
id = figure;
subplot(2,2,1);imshow(img);title 'Module du gradient'
subplot(2,2,2);imshow(im1);title 'Image seuil bas';
subplot(2,2,3);imshow(im2);title 'Image seuil haut';


%% Ajouter les points entre ces deux seuils qui sont connexes à un point de contour
    
% Initialisations image des contours
imc = im2;                  % Points de contours : points à 1 après seuillage haut
imc0 = im2;
imdiff = ones(size(imc));   % imc(iter)-imc(iter-1): permet de compter le nombre de points de contours ajoutés

% Effectuer le seuillage par hysteresis
iter = 0;
while sum(sum(imdiff)) > 0   % des points de contour ont été ajoutés
    iter= iter+1;
    % Rechercher les points de contour entre les deux seuils
    [x,y] = find(im1 & ~imc);

    % Pourcourir tous ces points et les ajouter s'ils ont un point de
    % contour dans leur voisinage
    for k=1:length(x)
        if x(k)>1 && y(k)>1 && x(k)<H && y(k)<W     % Pour ne pas traiter les pixels du bords
            if imc(x(k)-1, y(k)-1) || imc(x(k)-1, y(k)) || imc(x(k)-1, y(k)+1) || ...
               imc(x(k), y(k)-1) || imc(x(k), y(k)+1) || imc(x(k)+1, y(k)-1) || ...
               imc(x(k)+1, y(k)+1) || imc(x(k)+1, y(k))

                imc(x(k),y(k))=1;       % ajouter le pixel (x(k),y(k)) aux points de contour
            end
        end
    end

    % Calculer l'image différence des points de contour ajoutés
    imdiff = imc >0 & imc0 == 0;

    % Afficher
    subplot(2,2,4);imshow(imc);
    title (sprintf('Contour iter = %d',iter));
    figure(id);
    pause(0.1)

    % Réinitialiser
    imc0 = imc;
end

% % Sauvegarder les images seuillées
% imwrite(im1,'ims1','gif');
% imwrite(im2,'ims2','gif');

