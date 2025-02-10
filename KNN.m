%% 0: Clean up
clear all
clc
close all

% Load training data
features_45Hz_HighLoad = readmatrix('features_baseline_45Hz_HighLoad.dat');
features_45Hz_LightLoad = readmatrix('features_baseline_45Hz_LightLoad.dat');
features_50Hz_HighLoad = readmatrix('features_baseline_50Hz_HighLoad.dat');
features_50Hz_LightLoad = readmatrix('features_baseline_50Hz_LightLoad.dat');
features_faulty = readmatrix('features_defective_baseline_50Hz_HighLoad.dat');

% Remove 4th column
features_45Hz_HighLoad(:, 4) = [];
features_45Hz_LightLoad(:, 4) = [];
features_50Hz_HighLoad(:, 4) = [];
features_50Hz_LightLoad(:, 4) = [];
features_faulty(:, 4) = [];

% Load test data
features_test_45Hz_HighLoad = readmatrix('features_testing_45Hz_HighLoad.dat');
features_test_45Hz_LightLoad = readmatrix('features_testing_45Hz_LightLoad.dat');
features_test_50Hz_LightLoad = readmatrix('features_testing_50Hz_LightLoad.dat');

% Remove 4th column
features_test_45Hz_HighLoad(:, 4) = [];
features_test_45Hz_LightLoad(:, 4) = [];
features_test_50Hz_LightLoad(:, 4) = [];

% Combine features
features = [features_45Hz_HighLoad; features_45Hz_LightLoad; features_50Hz_HighLoad; features_50Hz_LightLoad; features_faulty];
features_test = [features_test_45Hz_HighLoad; features_test_45Hz_LightLoad; features_test_50Hz_LightLoad];

numFilesPerCondition = [62, 62, 62, 62, 62];

% Generate labels
labels = [zeros(1, numFilesPerCondition(1)), ...
          zeros(1, numFilesPerCondition(2)), ...
          zeros(1, numFilesPerCondition(3)), ...
          zeros(1, numFilesPerCondition(4)), ...
          ones(1, numFilesPerCondition(5))];
labels = labels';

% Standardize features
mean_features = mean(features);
std_features = std(features);
features_standardized = (features - mean_features) ./ std_features;

% Apply PCA for dimensionality reduction
[coeff, score, latent] = pca(features_standardized);

explained_variance = cumsum(latent) / sum(latent);
num_components = find(explained_variance >= 0.95, 1);

features_pca = score(:, 1:num_components);

tic;
% Train KNN model
knn_model = fitcknn(features_pca, labels, 'NumNeighbors', 5, 'Standardize', true);

% Cross-validation
cross_val_model = crossval(knn_model);
accuracy = 1 - kfoldLoss(cross_val_model);

fprintf('Cross-validation accuracy with KNN: %.2f%%\n', accuracy * 100);

% Test set preprocessing
features_test_standardized = (features_test - mean_features) ./ std_features;
features_test_pca = features_test_standardized * coeff(:, 1:num_components);

% Make predictions
predictions = predict(knn_model, features_test_pca);
comp_time = toc;
faulty_indices = find(predictions==1);

% Plot PCA-transformed training data (first two principal components)
figure;
scatter(features_pca(1:62,1), features_pca(1:62,2), 100, 'b', 'o'); % 45Hz High Load
hold on;
scatter(features_pca(63:124,1), features_pca(63:124,2), 100, 'b', 's'); % 45Hz Light Load
scatter(features_pca(125:186,1), features_pca(125:186,2), 100, 'b', '^'); % 50Hz High Load
scatter(features_pca(187:248,1), features_pca(187:248,2), 100, 'b', 'd'); % 50Hz Light Load
scatter(features_pca(249:end,1), features_pca(249:end,2), 100, 'r', 'x'); % Faulty eccentric samples
xlabel('Principal Component 1');
ylabel('Principal Component 2');
title('KNN Training Data - Healthy vs Faulty');
legend({'45Hz Heavy Load', '45Hz Light Load', '50Hz High Load','50Hz Light Load', 'Faulty Eccentric Samples'});

% Plot PCA-transformed test data with predictions
figure;
scatter(features_test_pca(1:20,1), features_test_pca(1:20,2), 100, 'b', 'o'); % 45Hz Heavy Load
hold on;
scatter(features_test_pca(21:40,1), features_test_pca(21:40,2), 100, 'b', 's'); % 45Hz Light Load
scatter(features_test_pca(41:60,1), features_test_pca(41:60,2), 100, 'b', '^'); % 50 Hz Light Load
scatter(features_test_pca(faulty_indices,1),features_test_pca(faulty_indices,2),100,'r');
xlabel('Principal Component 1');
ylabel('Principal Component 2');
title('KNN Test Data - Preditions');
legend({'45Hz Heavy Load', '45Hz Light Load', '50Hz Light Load', 'Predicted Faulty'});

labels_test = zeros(60,1); % Example for C1, C2, C3
labels_test(faulty_indices) = 1;
labels_test = labels_test';

figure;
confusionchart(labels_test,predictions);
title('Confusion matrix KNN-test data');

% True Positives, True Negatives, False Positives, False Negatives
TP = sum(labels_test == 1 & predictions == 1);
TN = sum(labels_test == 0 & predictions == 0);
FP = sum(labels_test == 0 & predictions == 1);
FN = sum(labels_test == 1 & predictions == 0);

% Calculate metrics
accuracy = (TP + TN) / (TP + TN + FP + FN);
precision = TP / (TP + FP);
recall = TP / (TP + FN);
f1 = 2 * (precision * recall) / (precision + recall);

fprintf('KNN Metrics:\n');
fprintf('Accuracy: %.2f\n', accuracy);
fprintf('Precision: %.2f\n', precision);
fprintf('Recall: %.2f\n', recall);
fprintf('F1 Score: %.2f\n\n', f1);
fprintf('Compuatational Time: %.2f\n\n', comp_time);


