clc; clear; close all;

% --- Φόρτωση και Προετοιμασία Εικόνας ---
img = imread('board.png');
if size(img, 3) == 3
    img = rgb2gray(img);
end
img = double(img);

blockSize = 32;

% Κάνουμε pad ώστε οι διαστάσεις να είναι πολλαπλάσια του 32
padH = mod(-size(img,1), blockSize);
padW = mod(-size(img,2), blockSize);
img = padarray(img, [padH padW], 'post');
[H, W] = size(img);

% --- Ορισμός Παραμέτρων ---
r_values = linspace(0.05, 0.5, 10);
mse_zone = zeros(size(r_values));
mse_thresh = zeros(size(r_values));

% --- Κύρια Επεξεργασία ---
for k = 1:length(r_values)
    r = r_values(k);
    rec_zone = zeros(H, W);
    rec_thresh = zeros(H, W);

    for i = 1:blockSize:H
        for j = 1:blockSize:W
            block = img(i:i+blockSize-1, j:j+blockSize-1);

            % DCT
            dct_block = dct2(block);

            % Μέθοδος Ζώνης
            dct_z = keep_zone(dct_block, r);
            rec_block_z = idct2(dct_z);

            % Περιορισμός τιμών στο [0, 255]
            rec_block_z = min(max(rec_block_z, 0), 255);
            rec_zone(i:i+blockSize-1, j:j+blockSize-1) = rec_block_z;

            % Μέθοδος Κατωφλίου
            dct_t = keep_thresh(dct_block, r);
            rec_block_t = idct2(dct_t);
            rec_block_t = min(max(rec_block_t, 0), 255);
            rec_thresh(i:i+blockSize-1, j:j+blockSize-1) = rec_block_t;
        end
    end

    % Υπολογισμός MSE
    mse_zone(k) = mean((img(:) - rec_zone(:)).^2);
    mse_thresh(k) = mean((img(:) - rec_thresh(:)).^2);

    fprintf('r = %.2f --> MSE (Ζώνης): %.2f, MSE (Κατωφλίου): %.2f\n', ...
    r, mse_zone(k), mse_thresh(k));


    % Εμφάνιση εικόνων για επιλεγμένες τιμές r
 if ismember(r, [0.05, 0.1, 0.25, 0.5])
        figure('Units', 'normalized', 'Position', [0.1 0.3 0.8 0.4]);
        subplot(1,3,1);
        imshow(uint8(img));
        title('Αρχική');

        subplot(1,3,2);
        imshow(uint8(rec_zone));
        title(['Κωδικοποίηση ζώνης με r = ' num2str(r*100) '%']);

        subplot(1,3,3);
        imshow(uint8(rec_thresh));
        title(['Κωδικοποίηση κατωφλίου με r = ' num2str(r*100) '%']);
    end
end

% --- Γράφημα Αποτελεσμάτων ---
figure;
plot(r_values*100, mse_zone, 'o-', 'DisplayName', 'Zone Method'); hold on;
plot(r_values*100, mse_thresh, 'x-', 'DisplayName', 'Threshold Method');
xlabel('Percentage of DCT Coefficients Kept (%)');
ylabel('Mean Squared Error (MSE)');
title('DCT Compression Performance');
legend;
grid on;

%Συναρτήσεις που χρειάστηκαν

% Μέθοδος Ζώνης (Zone method)
function dct_z = keep_zone(dct_block, r)
    N = size(dct_block, 1);
    total = N * N;
    keep = round(r * total);

    [X, Y] = meshgrid(1:N, 1:N);
    % Ελαφρώς διαφοροποιημένο άθροισμα για μοναδική ταξινόμηση
    priority = X + Y + 0.001 * X;

    [~, sorted_indices] = sort(priority(:), 'ascend');
    mask = false(N);
    mask(sorted_indices(1:keep)) = true;

    dct_z = dct_block .* mask;
end

% Μέθοδος Κατωφλίου (Threshold method)
function dct_t = keep_thresh(dct_block, r)
    total = numel(dct_block);
    keep = round(r * total);

    % Βρες τις θέσεις των keep μεγαλύτερων σε μέγεθος συντελεστών
    [~, sorted_indices] = sort(abs(dct_block(:)), 'descend');
    mask = false(size(dct_block));
    mask(sorted_indices(1:keep)) = true;

    dct_t = dct_block .* mask;
end
