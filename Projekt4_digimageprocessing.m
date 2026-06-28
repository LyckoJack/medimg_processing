%% LOAD IMG
img = imread('normal-paranasal-sinuses-x-ray_v2.png');
% Reddit users say a "double" image preserve higher precision during image
% manpilation
img_double = double(img);
%% SIDE2SIDE blur effect (PSF)
%get size of image
[rows, cols] = size(img_double);
%create matrix for blurry img
img_blurred = zeros(rows, cols);

% Nos. of pixels of movement
L = 30; 
% Loop from top to bottom 
for r = 1:rows
    
    % Loop through every column from left to right 
    % stop 'L' pixels before the right edge so our slice doesn't go outside
    for c = 1:(cols - L)
        
        % Extract values from a slice of L pixels starting from row 'r', column 'c' 
        pixel_slice = img_double(r, c : (c + L - 1));
        
        % average the slice value
        slice_average = sum(pixel_slice) / L;
        
        % Save this average value into img_blurred matrix
        img_blurred(r, c) = slice_average;
        
    end
end

%% SHOW clean and blurred img
figure; 
imshow(img_double, []);
title('Original Clean X-ray');

figure;
imshow(img_blurred, []);
title('Distorted Image (Side-to-Side Motion)');

%% GAUSSIAN NOISE
%matrix of random noise, "randn" is standard normal (Gaussian)
%added 5 to make noise visible, otherwise very small diff
std = 5;
noise = std * randn(rows, cols);
img_blurred_noisy = img_blurred + noise;

%show image with added noise
figure;
imshow(img_blurred_noisy, []);
title('Distorted Image (blur + gaussian noise');

%% PSEUDOINVERSE filter
%go to freq domain with fourier
G = fft2(img_blurred_noisy);
L_est = 30;
%get the blur filter similar to before
[rows, cols] = size(img_double);
psf_padded = zeros(rows, cols);
psf_padded(1, 1:L_est) = ones(1, L_est) / L_est;

H = fft2(psf_padded);

%threshold (gamma) so pixelvalues close to zero dont destroy the img
gamma = 0.1;
%empty matrix
M_pseudo = zeros(rows, cols);
%check size of H and detetmine if greater than gamma -> safe
H_magn = abs(H);
safe_px = (H_magn >= gamma);
%inverse for safe pixels
M_pseudo(safe_px) = 1 ./ H(safe_px);

F_hat = G .* M_pseudo;
%fourier back to normal spatial img
img_restored = real(ifft2(F_hat));


figure;
imshow(img_restored, []);
title(['Restored Image using Pseudoinverse (\gamma = ' num2str(gamma) ')']);

%% WIENER
%create multiple slightly altered imgs 
% Initialize our accumulator to all zeros
S_f_accumulator = zeros(rows, cols);

% Define how many shifted versions we want to generate
num_versions = 10;

for k = 1:num_versions
    % Create an empty matrix for this version
    img_shifted_k = zeros(rows, cols);
    
    % Shift the image down and right by 'k' pixels.
    % slightly move alignment, simulating different pat. pos.
    img_shifted_k((k+1):end, (k+1):end) = img_double(1:(end-k), 1:(end-k));
    
    % convert to freq domain
    F_k = fft2(img_shifted_k);
    
    % Accumulate the power spectrum: |F(u,v)|^2
    S_f_accumulator = S_f_accumulator + (abs(F_k).^2);
end

% divide by num of versions for average
S_f = S_f_accumulator / num_versions;


%% WIENER FILTER constructed
% noise amplitude was 5, so variance is 25.
noise_variance = std ^ 2;
S_noise = rows * cols * noise_variance;
% Calculate |H|^2
H_mag_sq = abs(H).^2;

% Implement the exact Wiener formula: conj(H) ./ ( |H|^2 + (S_noise / S_f) )

M_wiener = conj(H) ./ (H_mag_sq + (S_noise ./ S_f));
    

% Multiply noisy and blurred image frequencies (G) by Wiener, aka G still
% fourier transformed
F_hat_wiener = G .* M_wiener;
% bring back in domain
img_restored_wiener = real(ifft2(F_hat_wiener));


%% Pseudoinverse vs Wiener vs Noisyblurred
figure;
imshow(img_restored_wiener, []);
title('Wiener');

figure;
subplot(1, 3, 1);
imshow(img_restored, []); 
title('Pseudoinverse');

subplot(1, 3, 2);
imshow(img_restored_wiener, []); 
title('Custom Wiener Filter');

subplot(1, 3, 3);
imshow(img_blurred_noisy, []);
title('Blurred n noisy');