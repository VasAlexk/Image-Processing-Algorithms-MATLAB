clear;
close all;

%% ======================== ΜΕΡΟΣ Α ========================
% Αποθορυβοποίηση με Φίλτρο Wiener

% Ανάγνωση εικόνας
I = im2double(imread('new_york.png'));

% Υπολογισμός ισχύος σήματος
signal_power = var(I(:));

% Υπολογισμός ισχύος θορύβου για SNR = 10dB
snr_db = 10;
snr_linear = 10^(snr_db/10);
noise_power = signal_power / snr_linear;

% Δημιουργία λευκού Gauss θορύβου
noise = sqrt(noise_power) * randn(size(I));

% Προσθήκη θορύβου στην εικόνα
I_noisy = I + noise;

% Προβολή εικόνας με θόρυβο
figure('Position',[100 100 400 350]);
imshow(I_noisy);
title('Εικόνα με Gauss Θόρυβο (SNR = 10dB)');

% Wiener φίλτρο με γνώση ισχύος θορύβου
I_wiener_known = wiener2(I_noisy, [5 5], noise_power);
figure('Position',[520 100 400 350]);
imshow(I_wiener_known);
title('Wiener (γνωστή ισχύς)');

% Wiener φίλτρο χωρίς γνώση ισχύος
I_wiener_unknown = wiener2(I_noisy, [5 5]);
figure('Position',[940 100 400 350]);
imshow(I_wiener_unknown);
title('Wiener (άγνωστη ισχύς)');

% Υπολογισμός PSNR
psnr_noisy = psnr(I_noisy, I);
psnr_known = psnr(I_wiener_known, I);
psnr_unknown = psnr(I_wiener_unknown, I);

fprintf('\n--- ΜΕΡΟΣ Α: Wiener Φίλτρο ---\n');
fprintf('PSNR εικόνας με θόρυβο: %.2f dB\n', psnr_noisy);
fprintf('PSNR αποκατάστασης (γνωστή ισχύς): %.2f dB\n', psnr_known);
fprintf('PSNR αποκατάστασης (άγνωστη ισχύς): %.2f dB\n', psnr_unknown);

%% ======================== ΜΕΡΟΣ Β ========================
% Αποσυνέλιξη με Αντίστροφο Φίλτρο

% PSF: Gaussian blur
psf = @(x) imfilter(x, fspecial('gaussian', 21, 3), 'circular');
Y = psf(I);  % Θολή εικόνα

% Εκτίμηση PSF μέσω impulse απόκρισης
impulse = zeros(size(I));
impulse(round(end/2), round(end/2)) = 1;
psf_kernel = psf(impulse);

% Προβολή εκτιμημένης PSF
figure('Position',[100 500 300 250]);
imshow(mat2gray(psf_kernel));
title('Εκτιμημένη PSF');

% Φασματική απόκριση της PSF
H = fft2(psf_kernel);
figure('Position',[420 500 300 250]);
imagesc(log(abs(fftshift(H)) + 1));
colormap gray;
title('Log-Magnitude H');

% FFT της θολωμένης εικόνας
Y_fft = fft2(Y);

% Δοκιμή διαφορετικών κατωφλίων
taus = [0, 0.001, 0.01, 0.05, 0.1];
mse_values = zeros(size(taus));

figure('Name','Αποτελέσματα Αποσυνέλιξης','Position',[740 500 600 400]);
for i = 1:length(taus)
    tau = taus(i);
    
    % Δημιουργία φίλτρου με κατώφλι
    H_abs = abs(H);
    H_inv = zeros(size(H));
    H_inv(H_abs > tau) = 1 ./ H(H_abs > tau);
    
    % Αποσυνέλιξη
    X_hat_fft = Y_fft .* H_inv;
    X_hat = real(ifft2(X_hat_fft));
    
    % MSE
    mse_values(i) = immse(X_hat, I);
    
    % Προβολή αποτελέσματος
    subplot(2, ceil(length(taus)/2), i);
    imshow(X_hat, []);
    title(['\tau = ' num2str(tau) ', MSE = ' num2str(mse_values(i), '%.4f')]);
end

% Διάγραμμα MSE
figure('Position',[100 850 400 300]);
plot(taus, mse_values, '-o', 'LineWidth', 2);
xlabel('Κατώφλι \tau');
ylabel('MSE');
title('Σφάλμα σε σχέση με το κατώφλι');
grid on;

% Βέλτιστο κατώφλι και PSNR
[~, best_idx] = min(mse_values);
best_tau = taus(best_idx);
H_inv_best = zeros(size(H));
H_inv_best(abs(H) > best_tau) = 1 ./ H(abs(H) > best_tau);
X_hat_best = real(ifft2(Y_fft .* H_inv_best));
psnr_val = psnr(X_hat_best, I);

fprintf('\n--- ΜΕΡΟΣ Β: Αποσυνέλιξη ---\n');
fprintf('Βέλτιστο κατώφλι: τ = %.4f με MSE = %.4f\n', best_tau, mse_values(best_idx));
fprintf('PSNR της αποκατεστημένης εικόνας: %.2f dB\n', psnr_val);
