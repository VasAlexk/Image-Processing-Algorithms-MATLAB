clc; clear; close all;

% Φόρτωση εικόνας
load('tiger.mat'); % Η εικόνα αποθηκεύεται ως μεταβλητή tiger
tiger = im2double(tiger);

% Υπολογισμός θορύβου για SNR = 15 dB
signal_power = var(tiger(:));
SNR = 15;
noise_power = signal_power / (10^(SNR / 10));

%% 1. Gaussian Θόρυβος
noisy_gauss = imnoise(tiger, 'gaussian', 0, noise_power);

avg_filtered = imfilter(noisy_gauss, fspecial('average', [3 3]));
median_filtered = medfilt2(noisy_gauss, [3 3]);

figure('Name','Gaussian Θόρυβος');
subplot(1,3,1); imshow(noisy_gauss); title('Gaussian Noise (15dB)');
subplot(1,3,2); imshow(avg_filtered); title('Με φίλτρο μέσου');
subplot(1,3,3); imshow(median_filtered); title('Με φίλτρο διαμέσου');

%% 2. Κρουστικός Θόρυβος (20%)
noisy_sp = imnoise(tiger, 'salt & pepper', 0.2);

avg_filtered_sp = imfilter(noisy_sp, fspecial('average', [3 3]));
median_filtered_sp = medfilt2(noisy_sp, [3 3]);

figure('Name','Κρουστικός Θόρυβος');
subplot(1,3,1); imshow(noisy_sp); title('Salt & Pepper 20%');
subplot(1,3,2); imshow(avg_filtered_sp); title('Με φίλτρο μέσου');
subplot(1,3,3); imshow(median_filtered_sp); title('Με φίλτρο διαμέσου');

%% 3. Συνδυασμένος Θόρυβος
combo_noise = imnoise(tiger, 'gaussian', 0, noise_power);
combo_noise = imnoise(combo_noise, 'salt & pepper', 0.2);

% Δοκιμή δύο σειρών φιλτραρίσματος
median_then_avg = imfilter(medfilt2(combo_noise, [3 3]), fspecial('average', [3 3]));
avg_then_median = medfilt2(imfilter(combo_noise, fspecial('average', [3 3])), [3 3]);

figure('Name','Συνδυασμένος Θόρυβος');
subplot(2,2,1); imshow(combo_noise); title('Gaussian + Salt & Pepper');
subplot(2,2,2); imshow(median_then_avg); title('1. Median → Μέσος');
subplot(2,2,3); imshow(avg_then_median); title('2. Μέσος → Median');
subplot(2,2,4); imshow(tiger); title('Αρχική εικόνα');
