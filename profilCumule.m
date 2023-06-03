function PC = profilCumule(image)

    H = size(image, 1);
    PC = zeros(1,H);           % Profil Cumulé
    for i=1:H
        PC(i) = sum(image(i,:));        % Somme les lignes
    end

end