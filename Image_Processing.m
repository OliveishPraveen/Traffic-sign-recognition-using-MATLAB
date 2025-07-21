clear; 
clc;

% Define the full image path
imagePath = 'C:\Users\namde\OneDrive\Desktop\red 2.jpeg';

% Read the original PNG image
a = imread(imagePath);

% Show variable info
whos
disp(imfinfo(imagePath)); % Show image metadata

% Write JPEG images with different quality levels
imwrite(a, 'p10.jpg', 'Quality', 10); 
imwrite(a, 'p5.jpg', 'Quality', 5); 
imwrite(a, 'p0.jpg', 'Quality', 0); 

% Read back the compressed JPEG images
b = imread('p10.jpg');
c = imread('p5.jpg'); 
d = imread('p0.jpg');

% Display all images in a 2x2 subplot
figure, 
subplot(2,2,1), imshow(a); title('Original PNG');
subplot(2,2,2), imshow(b); title('JPEG Quality 10');
subplot(2,2,3), imshow(c); title('JPEG Quality 5');
subplot(2,2,4), imshow(d); title('JPEG Quality 0');
