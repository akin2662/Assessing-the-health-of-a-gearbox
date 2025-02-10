clear
clc
tic;

%load training data A and train model
A = load('trainingDataFeatures.txt');
B = load('testingDataFeatures.txt');

max_A2 = max(A(:,2));
max_A3 = max(A(:,3));

A_health = [A(:,1) A(:,2) A(:,3)];
B_health = [B(:,1) B(:,2) B(:,3)];

%A_health = A;
%B_health = B;

%{
A_health(:,1) = A(:,1) * 0;
A_health(:,4) = A(:,4) * 0;
B_health(:,1) = B(:,1) * 0;
B_health(:,4) = B(:,4) * 0;
%}


 labels = {'H', 'F'}; 

 sD = som_data_struct(A_health);
 sD = som_label(sD,'add',[1:248],labels(1));
 sD = som_label(sD,'add',[249:310],labels(2));

sMap = som_make(sD);

sMap = som_autolabel(sMap,sD,'vote');
%% Visualize the maps

som_show(sMap);

% U-matrix with labels
figure;
som_show(sMap,'umat','all','empty','Labels');
som_show_add('label',sMap,'Textsize',8,'TextColor','r','Subplot',2)

%% See the hit points for different categories 

colormap(1-gray)
som_show(sMap,'umat','all','empty','Labels');

% Add labels to the map
som_show_add('label',sMap,'Textsize',8,'TextColor','r','Subplot',2)

% samples for test
h1 = som_hits(sMap,sD.data(10,:)); % data from H
h2 = som_hits(sMap,sD.data(280,:)); % data from I1

% diagnosis result
h1_label = sMap.labels(h1==1);
h2_label = sMap.labels(h2==1);

bmus = som_bmus(sMap, B_health);

B_labels = cell(length(bmus), 1);
for i = 1:length(bmus)
    % Check if the BMU has an assigned label
    if isempty(sMap.labels{bmus(i)})
        % Compute Euclidean distances between the BMU and all neurons
        distances = som_eucdist2(sMap.codebook(bmus(i),:), sMap.codebook);
        
        % Set distances of neurons without labels to infinity
        label_mask = ~cellfun('isempty', sMap.labels);
        distances(~label_mask) = inf;
        
        % Find the index of the closest labeled neuron
        [~, closest_bmu_idx] = min(distances);
        
        % Assign the label of the closest labeled neuron
        B_labels{i} = sMap.labels{closest_bmu_idx};
    else
        % Assign the label of the BMU if it has one
        B_labels{i} = sMap.labels{bmus(i)};
    end
end


B_true_labels = [repmat({'H'}, 60, 1)]; 
B_true_labels(1) = {'F'};
B_true_labels(4) = {'F'};
B_true_labels(5) = {'F'};
B_true_labels(6) = {'F'};
B_true_labels(8) = {'F'};
B_true_labels(9) = {'F'};
B_true_labels(14) = {'F'};
B_true_labels(16) = {'F'};
B_true_labels(17) = {'F'};
B_true_labels(18) = {'F'};
B_true_labels(19) = {'F'};
B_true_labels(20) = {'F'};


figure;
confusionchart(B_true_labels, B_labels, 'Normalization', 'row-normalized');
title('Confusion Matrix for Fault Classification');



nH = zeros(prod(sMap.topol.msize), 1);
nD = zeros(prod(sMap.topol.msize), 1);

for i = 1:length(bmus)
    if bmus(i) > 0 && bmus(i) <= prod(sMap.topol.msize)
        switch B_labels{i}
            case 'H'
                nH(bmus(i)) = nH(bmus(i)) + 1;
            case 'F'
                nD(bmus(i)) = nD(bmus(i)) + 1;
        end
    end
end

figure;
som_show(sMap, 'umat', 'all', 'empty', 'Labels');

som_show_add('hit', nH, 'MarkerColor', 'g', 'Subplot', 2); 
som_show_add('hit', nD, 'MarkerColor', 'r', 'Subplot', 2);

elapsed_time = toc;
disp(['Elapsed Time: ', num2str(elapsed_time), ' seconds']);

