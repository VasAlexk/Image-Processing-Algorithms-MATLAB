clear;
close all;

% Φόρτωση της αρχικής εικόνας
I = im2double(imread('new_york.png'));


% Άγνωστη PSF (δίδεται ως συνάρτηση)
psf = @(x) imfilter(x, fspecial('gaussian', 21, 3), 'circular');

% Θόλωση της εικόνας
Y = psf(I);

% Εκτίμηση της PSF μέσω απόκρισης μονάδας
impulse = zeros(size(I));
impulse(round(end/2), round(end/2)) = 1;
psf_kernel = psf(impulse);

% Οπτικοποίηση της εκτιμημένης PSF
figure; imshow(mat2gray(psf_kernel)); title('Εκτιμημένη PSF');

% Υπολογισμός της FFT της εκτιμημένης PSF
H = fft2(psf_kernel);
figure; imagesc(log(abs(fftshift(H)) + 1)); colormap gray;
title('Log-Magnitude του H');

% FFT της θολωμένης εικόνας
Y_fft = fft2(Y);

% Εύρος κατωφλίων για δοκιμή
taus = [0, 0.001, 0.01, 0.05, 0.1];

% Αποθήκευση MSE για κάθε κατώφλι
mse_values = zeros(size(taus));

% Δημιουργία σχήματος για απεικόνιση αποκατεστημένων εικόνων
figure;
for i = 1:length(taus)
    tau = taus(i);
    
    % Δημιουργία φίλτρου H_inv με κατώφλι
    H_abs = abs(H);
    H_inv = zeros(size(H));
    H_inv(H_abs > tau) = 1 ./ H(H_abs > tau);  % μόνο αν ξεπερνάει το κατώφλι

    % Εφαρμογή αντίστροφου φίλτρου
    X_hat_fft = Y_fft .* H_inv;
    X_hat = real(ifft2(X_hat_fft));

    % Υπολογισμός MSE
    mse_values(i) = immse(X_hat, I);

    % Εμφάνιση εικόνας
    subplot(2, ceil(length(taus)/2), i);
    imshow(X_hat, []);
    title(['\tau = ' num2str(tau) ', MSE = ' num2str(mse_values(i), '%.4f')]);
end

% Διάγραμμα MSE σε συνάρτηση με το κατώφλι
figure;
plot(taus, mse_values, '-o', 'LineWidth', 2);
xlabel('Κατώφλι \tau');
ylabel('MSE');
title('Σφάλμα σε συνάρτηση του κατωφλίου');
grid on;

% Προαιρετικά: Υπολογισμός και εμφάνιση PSNR για το καλύτερο κατώφλι
[~, best_idx] = min(mse_values);
best_tau = taus(best_idx);
fprintf('Βέλτιστο κατώφλι: τ = %.4f με MSE = %.4f\n', best_tau, mse_values(best_idx));

% Προαιρετικά: υπολογισμός PSNR
H_inv_best = zeros(size(H));
H_inv_best(abs(H) > best_tau) = 1 ./ H(abs(H) > best_tau);
X_hat_best = real(ifft2(Y_fft .* H_inv_best));
psnr_val = psnr(X_hat_best, I);
fprintf('PSNR της αποκατεστημένης εικόνας: %.2f dB\n', psnr_val);
