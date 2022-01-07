%% Task 1: work on the videosurveillance sequence using a simple background obtained as an 
% average between two empty frames

% load two empty images
B1 = double(rgb2gray(imread('EmptyScene01.jpg')));
B2 = double(rgb2gray(imread('EmptyScene02.jpg')));

% compute a simple background model
B = 0.5*(B1 + B2);

% load each image in the sequence, perform the change detection
% show the frame, the background and the binary map
% Observe how the results change as you vary the threshold

tau = 20;

FIRST_IDX = 250; %index of first image
LAST_IDX = 320; % index of last image

for t = FIRST_IDX : LAST_IDX
    
    filename = sprintf('videosurveillance/frame%4.4d.jpg', t);
    It = imread(filename);
    Ig = rgb2gray(It);
    
    Mt = (abs(double(Ig) - B) > tau);
    
    subplot(1, 3, 1), imshow(It);
    subplot(1, 3, 2), imshow(uint8(B));
    subplot(1, 3, 3), imshow(uint8(Mt*255));
    pause(0.5)

end

%% Task 2: working again on the videosurveillance sequence, use now a background model based 
% on running average to incorporate scene changes

% Let's use the first N  frames to initialize the background

FIRST_IDX = 250; %index of first image
LAST_IDX = 320; % index of last image

N = 5;

filename = sprintf('videosurveillance/frame%4.4d.jpg', FIRST_IDX);
B = double(rgb2gray(imread(filename)));
for t = FIRST_IDX+1 : FIRST_IDX + N-1
    
    filename = sprintf('videosurveillance/frame%4.4d.jpg', t);
    B = B + double(rgb2gray(imread(filename)));
    
end

B = B / N;

% Play with these parameters
TAU = 25; 
ALPHA = 0.01;

% Now start the change detection while updating the background with the
% running average. For that you have to set the values for TAU and ALPHA

Bprev = B;
for t = FIRST_IDX+N : LAST_IDX
    
    filename = sprintf('videosurveillance/frame%4.4d.jpg', t);
    
    It = imread(filename);
    Ig = rgb2gray(It);
    
    Mt = (abs(double(Ig) - Bprev) > TAU);

    % Implement the background update as a running average
    Bcurr = Bprev .* Mt + ((1-ALPHA) * Bprev + ALPHA * double(Ig)) .* (1-Mt);
    
%     keyboard
    subplot(1, 3, 1), imshow(It);
    subplot(1, 3, 2), imshow(uint8(Bcurr));
    subplot(1, 3, 3), imshow(uint8(Mt*255));
    pause(0.05)
    Bprev = Bcurr;
    
end


%% Task 3: Repeat the above experiment with the sequence frames_evento1 observing what happens as you change 
% the parameters TAU and ALPHA

FIRST_IDX = 4728; %index of first image
LAST_IDX = 6698; % index of last image

N = 5;

filename = sprintf('videosurveillance/frame%4.4d.jpg', FIRST_IDX);
B = double(rgb2gray(imread(filename)));
for t = FIRST_IDX+1 : FIRST_IDX + N-1
    
    filename = sprintf('videosurveillance/frame%4.4d.jpg', t);
    B = B + double(rgb2gray(imread(filename)));
    
end

B = B / N;

% Play with these parameters
TAU = 25; 
ALPHA = 0.01;

% Now start the change detection while updating the background with the
% running average. For that you have to set the values for TAU and ALPHA

Bprev = B;
for t = FIRST_IDX+N : LAST_IDX
    
    filename = sprintf('videosurveillance/frame%4.4d.jpg', t);
    
    It = imread(filename);
    Ig = rgb2gray(It);
    
    Mt = (abs(double(Ig) - Bprev) > TAU);
    
    % Implement the background update as a running average
    Bcurr = Bprev .* Mt + ((1-ALPHA) * Bprev + ALPHA * double(Ig)) .* (1-Mt);
    
%     keyboard
    subplot(1, 3, 1), imshow(It);
    subplot(1, 3, 2), imshow(uint8(Bcurr));
    subplot(1, 3, 3), imshow(uint8(Mt*255));
    pause(0.05)
    Bprev = Bcurr;
    
end


%% Task 4: Design a simple tracking system according to the following guidelines
% a. Initialize the background model 
% b. Initialize the tracking history to empty
% b. At each time instant
%       i. Apply the change detection to obtain the binary map
%      ii. Update the background model
%     iii. Identify the connected components in the binary map (see e.g.
%          the matlab function bwconncomp)
%      iv. Try to associate each connected component with a previously seen
%          target
% Hint 1 - It would be good to keep track of the entire trajectory and produce a visualization 
% that can be done either frame by frame (so you should see the trajectory built
% incrementally) or only at the end (in this case you will see the entire final trajectory)
% Hint 2 - How to decide that a trajectory is closed?

FIRST_IDX = 4728; %index of first image
LAST_IDX = 5126; % index of last image 6698

N = 5;

filename = sprintf('videosurveillance/frame%4.4d.jpg', FIRST_IDX);
B = double(rgb2gray(imread(filename)));
for t = FIRST_IDX+1 : FIRST_IDX + N-1
    
    filename = sprintf('videosurveillance/frame%4.4d.jpg', t);
    B = B + double(rgb2gray(imread(filename)));
    
end

B = B / N;

% Play with these parameters
TAU = 15; 
ALPHA = 0.01;
history = containers.Map; % History contains an id and the history of coordinates of the object
% Now start the change detection while updating the background with the
% running average. For that you have to set the values for TAU and ALPHA

Bprev = B;
for t = FIRST_IDX+N : LAST_IDX
    
    filename = sprintf('videosurveillance/frame%4.4d.jpg', t);
    
    It = imread(filename);
    Ig = rgb2gray(It);
    
    Mt = (abs(double(Ig) - Bprev) > TAU);
    tmp = imfill(Mt, 'holes');
    tmp = bwareaopen(tmp, 500);
    cc = bwconncomp(tmp);
    props = regionprops(cc, 'BoundingBox');
    % Implement the background update as a running average
    Bcurr = Bprev .* Mt + ((1-ALPHA) * Bprev + ALPHA * double(Ig)) .* (1-Mt);
    
    subplot(1,2,1), imshow(It)
    subplot(1,2,2), imshow(uint8(Mt * 255))
    hold on 
    for k = 1 : length(props) % for loop for all found moving objects
        bb = props(k).BoundingBox;
        center = [bb(1) + bb(3)/2, bb(2) + bb(4)/2]; % find the center coordinate of a moving object
        if (~isempty(history))
            added = 0;
            for i = 1:length(history)
                tmp = history(int2str(i));
                dist = abs(tmp(end,1) - center(1)) + abs(tmp(end,2) - center(2)); % this is needed to connect the new moving object to any of the existing in history dictionary
                % by comparing the center of the new moving object to the
                % last coordinate of existing moving objects in the
                % dictionary
                if dist < 50 % threshold for adding the new coordinate to existing objects
                    history(int2str(i)) = [history(int2str(i)); center];
                    added = 1;
                end
            end   
            if (~added) % if no objects close to the new moving object, we just add it as a new object
                history(int2str(history.Count + 1)) = center;
            end
            
        else % fill the dictionary with initial objects found as moving with each unique ID
            history(int2str(history.Count + 1)) = center;
        end
        xBox = [bb(1), bb(1)+bb(3), bb(1)+bb(3), bb(1), bb(1)]; % find the coordinates of the bounding box
        yBox = [bb(2), bb(2), bb(2)+bb(4), bb(2)+bb(4), bb(2)]; % find the coordinates of the bounding box
        plot(xBox, yBox, 'Color', [1, 0, 0]); % plot the bounding box
        hold on
        plot(center(1), center(2), '.', 'Color', [0, 1, 0]) % plot the center of the bounding box
        hold on
    end
    pause(0.01)
    Bprev = Bcurr;
end
hold on
tmp = history(int2str(4));
s = size(tmp);
plot([tmp(1,1),tmp(end,1)], [tmp(1,2),tmp(end,2)], 'Color', 'r', 'LineWidth', 3);
hold off