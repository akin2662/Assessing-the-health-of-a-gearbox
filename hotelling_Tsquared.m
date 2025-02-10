%% 0: Clean up
clear all
clc
close all

% Load and preprocess data 
features_45Hz_HighLoad = readmatrix('features_baseline_45Hz_HighLoad.dat');
features_45Hz_LightLoad = readmatrix('features_baseline_45Hz_LightLoad.dat');
features_50Hz_HighLoad = readmatrix('features_baseline_50Hz_HighLoad.dat');
features_50Hz_LightLoad = readmatrix('features_baseline_50Hz_LightLoad.dat');
features_faulty = readmatrix('features_defective_baseline_50Hz_HighLoad.dat');

% Remove condition type column
features_45Hz_HighLoad(:, 4) = [];
features_45Hz_LightLoad(:, 4) = [];
features_50Hz_HighLoad(:, 4) = [];
features_50Hz_LightLoad(:, 4) = [];
features_faulty(:, 4) = [];

% Combine training data
features = [features_45Hz_HighLoad; features_45Hz_LightLoad; features_50Hz_HighLoad; features_50Hz_LightLoad; features_faulty];

% Define labels for training data (0 for healthy, 1 for faulty)
numFilesPerCondition = [62, 62, 62, 62, 62];
labels = [zeros(1, numFilesPerCondition(1)), zeros(1, numFilesPerCondition(2)), ...
          zeros(1, numFilesPerCondition(3)), zeros(1, numFilesPerCondition(4)), ...
          ones(1, numFilesPerCondition(5))];
labels = labels';  % Convert to column vector

% Standardize features
mean_features = mean(features);
std_features = std(features);
features_standardized = (features - mean_features) ./ std_features;

% Perform PCA on standardized training data
[coeff, score, latent] = pca(features_standardized);

explained_variance = cumsum(latent) / sum(latent);
num_components = find(explained_variance >= 0.95, 1);  % Select number of components explaining at least 95% variance

% Project training data onto selected principal components
features_pca = score(:, 1:num_components);

tic;
%% Calculate Hotelling's T² statistic for training data
lambda_inv = diag(1 ./ latent(1:num_components));  % Inverse of eigenvalues (variance explained)
T2_train = sum((features_pca * lambda_inv) .* features_pca, 2);  % Hotelling's T²

%% Set control limit based on chi-squared distribution
alpha = 0.629;  % Confidence level
control_limit_T2 = chi2inv(alpha, num_components);  % Control limit

% Plot Hotelling's T² statistic for training data
figure;
plot(T2_train);
hold on;
yline(control_limit_T2, 'r--', 'Control Limit');
xlabel('Sample Index');
ylabel('T^2 Statistic');
title('Hotelling''s T^2 for Training Data');
legend('T^2', 'Control Limit');

%% Test Data Processing

% Load test data and preprocess (same as before)
features_test_45Hz_HighLoad = readmatrix('features_testing_45Hz_HighLoad.dat');
features_test_45Hz_LightLoad = readmatrix('features_testing_45Hz_LightLoad.dat');
features_test_50Hz_LightLoad = readmatrix('features_testing_50Hz_LightLoad.dat');

% Remove condition type column
features_test_45Hz_HighLoad(:, 4) = [];
features_test_45Hz_LightLoad(:, 4) = [];
features_test_50Hz_LightLoad(:, 4) = [];

% Combine test data
features_test = [features_test_45Hz_HighLoad; features_test_45Hz_LightLoad; features_test_50Hz_LightLoad];

% Standardize test data using training data's mean and standard deviation
features_test_standardized = (features_test - mean_features) ./ std_features;

% Project test data onto the same principal components as training data
features_test_pca = features_test_standardized * coeff(:, 1:num_components);

%% Calculate Hotelling's T² statistic for test data
T2_test = sum((features_test_pca * lambda_inv) .* features_test_pca, 2); 

%% Detect Faults Based on T² Statistic

faulty_samples_train = find(T2_train > control_limit_T2); % Faults in training data
faulty_samples_test = find(T2_test > control_limit_T2);   % Faults in test data

comp_time = toc;

% Plot Hotelling's T² statistic for test data
figure;
plot(T2_test);
hold on;
yline(control_limit_T2, 'r--', 'Control Limit');
xlabel('Sample Index');
ylabel('T^2 Statistic');
title('Hotelling''s T^2 for Test Data');
legend('T^2', 'Control Limit');

fprintf('Number of faulty samples in training: %d\n', length(faulty_samples_train));
fprintf('Number of faulty samples in test: %d\n', length(faulty_samples_test));

% Plot Training Data
figure;
scatter(features_pca(1:62,1), features_pca(1:62,2), 100, 'b', 'o'); % 45Hz Heavy Load
hold on;
scatter(features_pca(63:124,1), features_pca(63:124,2), 100, 'b', 's'); % 45Hz Light Load
scatter(features_pca(125:186,1), features_pca(125:186,2), 100, 'b', '^'); % 50Hz Heavy Load
scatter(features_pca(187:248,1), features_pca(187:248,2), 100, 'b', 'd'); % 50Hz Light Load
scatter(features_pca(249:end,1), features_pca(249:end,2), 100, 'r', 'x'); % Faulty eccentric samples
xlabel('Principal Component 1');
ylabel('Principal Component 2');
title('Hotellings Tsquared Training Data - Healthy vs Faulty');
legend({'45Hz Heavy Load', '45Hz Light Load', '50Hz Heavy Load','50Hz Light Load', 'Faulty Eccentric Samples'});


% Plot Test Data
figure;
scatter(features_test_pca(1:20,1), features_test_pca(1:20,2), 100, 'b', 'o'); % 45Hz Heavy Load
hold on;
scatter(features_test_pca(21:40,1), features_test_pca(21:40,2), 100, 'b', 's'); % 45Hz Light Load
scatter(features_test_pca(41:60,1), features_test_pca(41:60,2), 100, 'b', '^'); % 50Hz Light Load
scatter(features_test_pca(faulty_samples_test,1),features_test_pca(faulty_samples_test,2),100,'r');
xlabel('Principal Component 1');
ylabel('Principal Component 2');
title('Hotellings T-Squared Test Data - Preditions');
legend({'45Hz Heavy Load', '45Hz Light Load', '50Hz Light Load', 'Predicted Faulty'});

labels_test = zeros(60,1);
faulty_indices = [1, 4, 5, 6, 8, 9, 14, 16, 17, 18, 19, 20];
labels_test(faulty_indices) = 1;

predictions_test = zeros(size(T2_test));
predictions_test(faulty_samples_test) = 1;

figure;
confusionchart(labels_test,predictions_test);
title('Confusion matrix Hotelling T-squared- Test data');

% True Positives, True Negatives, False Positives, False Negatives
TP = sum(labels_test == 1 & predictions_test == 1);
TN = sum(labels_test == 0 & predictions_test == 0);
FP = sum(labels_test == 0 & predictions_test == 1);
FN = sum(labels_test == 1 & predictions_test == 0);

% Calculate metrics
accuracy = (TP + TN) / (TP + TN + FP + FN);
precision = TP / (TP + FP);
recall = TP / (TP + FN);
f1 = 2 * (precision * recall) / (precision + recall);

fprintf('Hotellings T-Squared Metrics:\n');
fprintf('Accuracy: %.2f\n', accuracy);
fprintf('Precision: %.2f\n', precision);
fprintf('Recall: %.2f\n', recall);
fprintf('F1 Score: %.2f\n\n', f1);
fprintf('Compuatational Time: %.2f\n\n', comp_time);


