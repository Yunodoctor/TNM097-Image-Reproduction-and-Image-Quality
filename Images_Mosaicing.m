%% Read original image
%Solros = SunFlower.jpeg
%Porträtt = image0195.jpg
%Dark = DarkImage.jpg
%Landskap = LandscapeNature.jpg
imgRGB = imread('DarkImage.jpg');

%imshow(imgRGB);
%% Scale image orginal image
imgDimension = size(imgRGB(:,:,1));

%Specify image height and width
imgHeight = imgDimension(1);
imgWidth = imgDimension(2);

%If the image is already square
if(imgHeight == imgWidth)
    imgCropped = imgRGB;
end
%Portrait, if image height is larger than image width
if(imgHeight > imgWidth)
    ymin = (imgHeight - imgWidth)/2;
    xmin = 0;
%Landscape image
else
    xmin = (imgWidth - imgHeight)/2;
    ymin = 0;
end
    
side = min(imgDimension); %shortest side of image
imgCropped = imcrop(imgRGB, [round(xmin) round(ymin) side side-1]);% imcrop(Image, [xmin, ymin width height])

%Resize image depending on if it is to small/big
if(side < 20)
    disp('Your images size is to small and have been resized to a 20x20 pixel image. This may effect the image apperence');
    imgResized = imresize(imgCropped, [80 80]);
else
    disp('Your images size is to big and have been resized to a 20x20 pixel image. This may effect the image apperence');
    imgResized = imresize(imgCropped, [80 80]);
end

imshow(imgResized);
%% Läs in små bilderna från databasen
folderPath = 'H:\TNM097\Projekt\Databas';
filePattern = dir(fullfile(folderPath, '*.jpg'));

for i = 1:length(filePattern)
    fileName = filePattern(i).name;
    fullName = fullfile(folderPath, fileName);
    fprintf(1, 'Reading images %s\n', fullName);
    imageArray = imread(fullName);
    
    croppedDatabaseImage = imresize(imageArray, [20 20]);
    %Save database as RG
    databaseRGB{i} = croppedDatabaseImage;
    
    %Save database as LAB
    imageArray2Lab = rgb2lab(croppedDatabaseImage);
    databaseLAB{i} = imageArray2Lab;
    
end
dataBase2 = databaseLAB;
%% Skala ned databasen till 100st bilder
databaseLAB = dataBase2;

%threshold = 10 ger 101 bilder i databasen
%threshold = 22 ger 54 bilder i databasen
%threshold = 28 ger 28 bilder i databasen

threshold = 10;
counter = 1;
for n = 1:length(databaseLAB)
    for m = n+1:length(dataBase2)
        nImg = databaseLAB{n};
        
        %Avst?nd f?rg (n) och f?rg (m)
        mImg = dataBase2{m};
        minDist = mean2(sqrt((nImg-mImg).^2));

        %Minsta f?rgskillnader
        if(minDist > threshold)
            %newDatabaseLAB10{counter} = mImg;
            newDatabaseLAB{counter} = mImg;
            %newDatabaseLAB28{counter} = mImg;
            counter = counter + 1;
            dataBase2(:,m) = [];
        end
        break      
    end
end

%% 
newImage = rgb2lab(imgResized);

clear indexVidPixel; %Rensa tidigare producerad bild

%Gå igenom alla bilder i databasen och jämför mot den pixeln vi är på nu i den stora for-loopen 
for i = 1:size(newImage,1)
    for j = 1:size(newImage,2)
        newImage_L = newImage(i,j,1);
        newImage_A = newImage(i,j,2);
        newImage_B = newImage(i,j,3);
        
         NewDiffernce = 100;%(newImage_L-databasL(1)......)

        for k = 1:length(newDatabaseLAB)
            currentImg = newDatabaseLAB{k};
            databaseL = currentImg(:,:,1);       
            databaseA = currentImg(:,:,2);
            databaseB = currentImg(:,:,3);   

            difference = mean2(sqrt((newImage_L-databaseL).^2+(newImage_A-databaseA).^2 +(newImage_B-databaseB).^2));
            
            if(difference < NewDiffernce) 
                NewDiffernce = difference;
                %k blir det indexet (n?r denna ?r klar) som ger den
                %faktiska bilden f?r just denna pixeln
                indexVidPixel(i,j) = k;   
                
            end
         end
    end
end
%% Aterskapadbild = indexVidPixel(i,j)
%theFinalImage = zeros(size(newImage,1),size(newImage,2),3);
sizeOfImages = size(newDatabaseLAB{1},1);
RangeX = 1:(size(croppedDatabaseImage,1)):(size(indexVidPixel,1)*sizeOfImages+1);     %Sätter upp storleken på slutbilden
RangeY = 1:(size(croppedDatabaseImage,2)):(size(indexVidPixel,2)*sizeOfImages+1);     %Då varje bild motsvarar 128x128 pixlar

%% Loop for recreating original image with small images
for a = 1:size(indexVidPixel,1)
    for b = 1:size(indexVidPixel,2)
        for index = 1:length(newDatabaseLAB)
            
            if(indexVidPixel(a,b) == index)
                theFinalImage(RangeX(a):RangeX(a+1)-1,RangeY(b):RangeY(b+1)-1,:) = newDatabaseLAB{indexVidPixel(a,b)};
            end
        end
    end
end

%imshow(theFinalImage);
%figure;
test = lab2rgb(theFinalImage);
imshow(test);

%% Kvalitetsm?tt
%M?ste rezise så den reproducerade bilden är lika stor som originalsolrosbilden för annars fungerar inte SSIM
doubleCropped = imresize(imgCropped, [1600 1600]);
doubleCropped1 = im2double(doubleCropped);

%Ska vara ett h?gt v?rde(?)
%snr_distort1 = snr(doubleCropped, resizeTest);

%SSIM ska vara s? n?ra ett som m?jligt
%window = ones(20, 20, 3);
%K = [0.01 0.03];
ssim_distort1 = ssim(doubleCropped1, test);


%%
imshow(resizeTest);



