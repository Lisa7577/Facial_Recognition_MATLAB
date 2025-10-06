clc;
clear;
close all;

% Ajoutez les fonctions nécessaires pour la détection de visages

% Dossier contenant les photos
repertoire = 'chemin_du_dossier_des_photos'; % Remplacez par le chemin de votre dossier
fichiers = dir(fullfile(repertoire, '*.jpg')); % Recherche des fichiers .jpg

% Crée un dossier pour sauvegarder les images corrigées
dossier_corrigees = fullfile(repertoire, 'Corrigees');
if ~exist(dossier_corrigees, 'dir')
    mkdir(dossier_corrigees);
end

for i = 1:length(fichiers)
    % Charger le fichier image
    chemin_image = fullfile(repertoire, fichiers(i).name);
    img = imread(chemin_image);
    fprintf('Traitement de l\image %s...\n', fichiers(i).name);

    % Lire les métadonnées EXIF
    info = imfinfo(chemin_image);
    if isfield(info, 'Orientation')
        orientation = info.Orientation;
    else
        orientation = 1; % Par défaut si pas d'information d'orientation
    end

    % Corriger l'orientation à partir des métadonnées EXIF
    switch orientation
        case 1
            % Orientation correcte, rien à faire
        case 3
            % Image à pivoter de 180 degrés
            img = imrotate(img, 180);
        case 6
            % Image à pivoter de 90 degrés dans le sens horaire
            img = imrotate(img, -90);
        case 8
            % Image à pivoter de 90 degrés dans le sens anti-horaire
            img = imrotate(img, 90);
        otherwise
            fprintf('Orientation inconnue pour %s, vérification manuelle...\n', fichiers(i).name);
    end

    % Détection de visages pour vérifier l'orientation
    bbox = step(faceDetector, img); % Détecte les visages
    if isempty(bbox)
        fprintf('Aucun visage détecté pour %s, image inchangée.\n', fichiers(i).name);
    else
        % Si un visage est détecté, ajustez l'image pour qu'il soit en haut
        [h, w, ~] = size(img);
        for j = 1:size(bbox, 1)
            centerY = bbox(j, 2) + bbox(j, 4) / 2;
            if centerY > h / 2
                fprintf('Rotation manuelle nécessaire pour %s.\n', fichiers(i).name);
                img = imrotate(img, 180); % Retourne l'image si le visage est à l'envers
                break;
            end
        end
    end

    % Sauvegarder l'image corrigée
    chemin_corrige = fullfile(dossier_corrigees, fichiers(i).name);
    imwrite(img, chemin_corrige);
    fprintf('Image %s corrigée et sauvegardée.\n', fichiers(i).name);
end

disp('Toutes les images ont été traitées.');
