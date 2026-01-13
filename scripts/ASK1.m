%Βήμα 1: Προεπεξεργασία 

img = imread('moon.jpg');

% Αν η εικόνα είναι RGB (3 διαστάσεων), μετατροπή σε grayscale
if ndims(img) == 3
    img = rgb2gray(img);
end

img = double(img); % Για αριθμητική ακρίβεια


% Γραμμικός μετασχηματισμός στη δυναμική περιοχή [0,255]
img = 255 * (img - min(img(:))) / (max(img(:)) - min(img(:)));

% Μετατόπιση του μηδενικού σημείου συχνοτήτων στο κέντρο
[M, N] = size(img);
shifted_img = img .* (-1).^(repmat((0:M-1)',1,N) + repmat(0:N-1,M,1)); 

%Βήμα 2: Υπολογισμός 2D DFT μέσω 1D DFT

% 1D DFT κατά γραμμές
F_row = zeros(M, N);
for i = 1:M
    F_row(i,:) = fft(shifted_img(i,:));
end

% 1D DFT κατά στήλες
F = zeros(M, N);
for j = 1:N
    F(:,j) = fft(F_row(:,j));
end

% Γραμμική απεικόνιση μέτρου
figure;
imshow(uint8(abs(F)/max(abs(F(:))) * 255));
title('Γραμμική απεικόνιση του πλάτους DFT');

% Λογαριθμική απεικόνιση μέτρου
figure;
imshow(log(1 + abs(F)), []);
title('Λογαριθμική απεικόνιση του πλάτους DFT');

%Βήμα 3: Φιλτράρισμα με κατωπερατό φίλτρο (Low-Pass Filter)

% Δημιουργία ιδανικού κατωπερατού φίλτρου
D0 = 50; % Ακτίνα ζώνης διάβασης
[U, V] = meshgrid(0:N-1, 0:M-1);
U = U - floor(N/2);
V = V - floor(M/2);
D = sqrt(U.^2 + V.^2);
H = double(D <= D0); % Ιδανικό κατωπερατό φίλτρο

% Εφαρμογή φίλτρου
G = F .* H;

% Βήμα 4: Αντίστροφος 2D DFT μέσω 1D IDFT

% 1D IDFT κατά στήλες
G_col = zeros(M, N);
for j = 1:N
    G_col(:,j) = ifft(G(:,j));
end

% 1D IDFT κατά γραμμές
g = zeros(M, N);
for i = 1:M
    g(i,:) = ifft(G_col(i,:));
end

% Πραγματικό μέρος
g = real(g);

%Βήμα 5: Αντιστροφή μετατόπισης (επαναφορά του (0,0))

% Επαναφορά του (0,0) σημείου στο αρχικό
final_img = g .* (-1).^(repmat((0:M-1)',1,N) + repmat(0:N-1,M,1));

% Προβολή τελικής εικόνας
figure;
imshow(uint8(final_img));
title('Τελική φιλτραρισμένη εικόνα');
