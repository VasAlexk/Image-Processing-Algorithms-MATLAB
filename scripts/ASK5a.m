clear;
close all;

% Ανάγνωση εικόνας
I = im2double(imread('new_york.png'));

% Υπολογισμός ισχύος σήματος
signal_power = var(I(:));

% Υπολογισμός ισχύος θορύβου για SNR = 10dB
snr_db = 10;
snr_linear = 10^(snr_db/10);
noise_power = signal_power / snr_linear;

% Δημιουργία λευκού θορύβου Gauss
noise = sqrt(noise_power) * randn(size(I));

% Εικόνα με θόρυβο
I_noisy = I + noise;

% Προβολή της εικόνας με θόρυβο σε μικρότερο παράθυρο
figure('Position', [100, 100, 400, 300]);
imshow(I_noisy);
title('Εικόνα με Gauss Θόρυβο (SNR = 10dB)');

% Wiener φίλτρο με γνώση της ισχύος του θορύβου
I_wiener_known = wiener2(I_noisy, [5 5], noise_power);

figure('Position', [100, 100, 250, 200]);
imshow(I_wiener_known);
title('Αποκατάσταση με Wiener (γνωστή ισχύς θορύβου)');

% Wiener φίλτρο χωρίς γνώση της ισχύος του θορύβου (προεπιλογή)
I_wiener_unknown = wiener2(I_noisy, [5 5]);

figure('Position', [100, 100, 250, 200]);
imshow(I_wiener_unknown);
title('Αποκατάσταση με Wiener (χωρίς γνώση θορύβου)');

% Υπολογισμός PSNR για σύγκριση
psnr_noisy = psnr(I_noisy, I);
psnr_known = psnr(I_wiener_known, I);
psnr_unknown = psnr(I_wiener_unknown, I);

fprintf('PSNR εικόνας με θόρυβο: %.2f dB\n', psnr_noisy);
fprintf('PSNR αποκατάστασης (γνωστή ισχύς): %.2f dB\n', psnr_known);
fprintf('PSNR αποκατάστασης (άγνωστη ισχύς): %.2f dB\n', psnr_unknown);

