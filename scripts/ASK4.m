clc; clear; close all;
% Λίστα εικόνων
images = {'dark_road_1.jpg', 'dark_road_2.jpg', 'dark_road_3.jpg'};

windowSize = [8 8];  % 8x8 πλακίδια για CLAHE
clipLimit = 0.01;    % Όριο περικοπής για CLAHE, συνήθως 0.01 ή 0.02

for i = 1:length(images)
    % Διαβάζουμε την εικόνα
    I = imread(images{i});
    
    % Μετατροπή σε grayscale με ασφαλή τρόπο
    try
        I_gray = im2gray(I);  % MATLAB >= R2021a
    catch
        if size(I, 3) == 3
            I_gray = rgb2gray(I);  % MATLAB < R2021a
        else
            I_gray = I; % Ήδη grayscale
        end
    end
    
    % === 1. Αρχική Εικόνα και Ιστόγραμμα ===
    figure('Name', ['Αρχική εικόνα και ιστόγραμμα - ', images{i}]);
    subplot(1,2,1); imshow(I_gray); title(['Αρχική εικόνα - ', images{i}]);
    subplot(1,2,2); imhist(I_gray); title('Ιστόγραμμα αρχικής');
    
    % === 2. Ολική Εξίσωση Ιστογράμματος ===
    I_eq = histeq(I_gray);
    
    % === 3. Τοπική Εξίσωση Ιστογράμματος (CLAHE) ===
    I_adapt = adapthisteq(I_gray, 'NumTiles', windowSize, 'ClipLimit', clipLimit);
    
    % === Ενιαία Εμφάνιση Αποτελεσμάτων για Σύγκριση ===
    figure('Name', ['Σύγκριση Εξίσωσης Ιστογράμματος - ', images{i}]);
    
    subplot(3,2,1); imshow(I_gray); title('1. Αρχική Εικόνα');
    subplot(3,2,2); imhist(I_gray); title('Ιστόγραμμα Αρχικής');
    
    subplot(3,2,3); imshow(I_eq); title('2. Ολική Εξίσωση');
    subplot(3,2,4); imhist(I_eq); title('Ιστόγραμμα Ολικής');
    
    subplot(3,2,5); imshow(I_adapt); title('3. Τοπική Εξίσωση (CLAHE)');
    subplot(3,2,6); imhist(I_adapt); title('Ιστόγραμμα Τοπικής (CLAHE)');
    
   
end