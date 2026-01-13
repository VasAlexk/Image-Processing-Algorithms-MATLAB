% Φόρτωση εικόνας
img = imread('hallway.png');

% Αν η εικόνα είναι RGB, μετατροπή σε grayscale
if size(img, 3) == 3
    gray = im2gray(img);
else
    gray = img;
end

% 1. Ανίχνευση ακμών με Sobel
sobel_x = fspecial('sobel');
sobel_y = sobel_x';

grad_x = imfilter(double(gray), sobel_x, 'replicate');
grad_y = imfilter(double(gray), sobel_y, 'replicate');
gradient_magnitude = sqrt(grad_x.^2 + grad_y.^2);

% Εμφάνιση αποτελέσματος Sobel
figure, imshow(uint8(gradient_magnitude)), title('Sobel Magnitude');

% 2. Ολική κατωφλίωση
threshold = 0.25 * max(gradient_magnitude(:));
binary_edges = gradient_magnitude > threshold;

figure, imshow(binary_edges), title(['Κατωφλίωση με T = ', num2str(threshold)]);

% 3. Bonus: Μετασχηματισμός Hough
[H, theta, rho] = hough(binary_edges);
peaks = houghpeaks(H, 10, 'threshold', ceil(0.3 * max(H(:))));
lines = houghlines(binary_edges, theta, rho, peaks, 'FillGap', 10, 'MinLength', 30);

% Εμφάνιση ευθύγραμμων τμημάτων στην αρχική εικόνα
figure, imshow(img), title('Ευθύγραμμα τμήματα (Hough)'), hold on
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'cyan');
end
