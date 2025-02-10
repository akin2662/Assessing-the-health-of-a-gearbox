%% 0: Clean up
clear all
clc
close all

%% 1: Set file path, importing data, and FFT
% Define the paths to the datasets
folder1 = 'G:\My Drive\Courses\Industry AI\Industry AI - Group Project\Final Project\Project 2\Training_DataSet\Baseline_45Hz_HighLoad';
folder2 = 'G:\My Drive\Courses\Industry AI\Industry AI - Group Project\Final Project\Project 2\Training_DataSet\Baseline_45Hz_LightLoad';
folder3 = 'G:\My Drive\Courses\Industry AI\Industry AI - Group Project\Final Project\Project 2\Training_DataSet\Baseline_50Hz_HighLoad';
folder4 = 'G:\My Drive\Courses\Industry AI\Industry AI - Group Project\Final Project\Project 2\Training_DataSet\Baseline_50Hz_LightLoad';
folder5 = 'G:\My Drive\Courses\Industry AI\Industry AI - Group Project\Final Project\Project 2\Training_DataSet\EccentricGear_50Hz_HighLoad';
folder6 = 'G:\My Drive\Courses\Industry AI\Industry AI - Group Project\Final Project\Project 2\Testing_DataSet\Test_45Hz_HighLoad';

Fsamp = 66664;      % Sampling frequency
N = 66664;          % Signal length
dt = 1/Fsamp;       % Time interval
t = dt:dt:1;        % Time vector
f = Fsamp*(0:(N/2))/N;  % Frequency vector for plotting FFT
fig = 1;            % Figure counter

sideband_window = 6;

% Preallocate storage arrays for features
numConditions = 5;
numFiles = 62; % Adjust based on the number of files in each folder
rms_acc1 = zeros(numFiles, numConditions);
peak2peak_acc1 = zeros(numFiles, numConditions);
kurtosis_acc1 = zeros(numFiles, numConditions);

% Loop through each folder (condition)
for j = 1:numConditions
    
    % Select folder based on condition
    switch j
        case 1
            folder = folder1;
            targetf = 45;
        case 2
            folder = folder2;
            targetf = 45;
        case 3
            folder = folder3;
            targetf = 50;
        case 4
            folder = folder4;
            targetf = 50;
        case 5
            folder = folder5;
            targetf = 50;
    end
    
    % List all .mat files in the folder
    filepattern = fullfile(folder, '*.mat');
    textfiles = dir(filepattern);
    
    % Loop through each file in the folder
    for i = 1:length(textfiles)
        % Load the data
        healthyfileName = textfiles(i).name;
        filename = fullfile(textfiles(i).folder, healthyfileName);
        fulldata = load(filename);
        data = fulldata.Gearbox.Data;
        acc1 = data(:,1);  % Input accelerometer data
        acc2 = data(:,2);  % Output accelerometer data
        tach = data(:,3);  % Tachometer data
        
        % Time-domain features
        rms_acc1(i, j) = rms(acc1);
        rms_acc2(i, j) = rms(acc2);
        rms_ratio(i, j) = rms(acc2)/rms(acc1);
        peak2peak_acc1(i, j) = max(acc1) - min(acc1);
        kurtosis_acc1(i, j) = kurtosis(acc1);
        
        % Frequency-domain analysis (FFT and sidebands)
        fft_acc1 = fft(acc1);
        P1_acc1 = abs(fft_acc1/N);

        %Amplitude at 1X        
        indices = (f > (targetf - sideband_window)) & (f < (targetf + sideband_window));
        band_frequencies = f(indices);
        band_amplitudes = P1_acc1(indices);
        [peak_acc1_aux, max_index] = max(band_amplitudes);
        fundamentalf_aux = band_frequencies(max_index);

        peak_acc1(i,j) = peak_acc1_aux;
        fundamentalf(i,j) = fundamentalf_aux;

        % Plot time-domain data for sample file (arbitrary selection)
        %{
        if i == 40
            figure(fig)
            plot(t, acc1, 'r', 'DisplayName', 'Input Acc.');
            hold on;
            plot(t, acc2, 'b', 'DisplayName', 'Output Acc.');
            xlabel('Time [s]');
            ylabel('Acceleration [m/s^2]');
            title(['Time-Domain Signal - Condition ' num2str(j)]);
            legend();
            fig = fig + 1;
        end
        
        % Plot frequency-domain data for sample file
        if i == 40
            figure(fig)
            plot(f, P1_acc1(1:N/2+1), 'r', 'DisplayName', 'Input Acc.');
            hold on;
            xlabel('Frequency [Hz]');
            ylabel('Amplitude');
            title(['Frequency-Domain Signal - Condition ' num2str(j)]);
            xlim([0 500]);
            legend();
            fig = fig + 1;
        end
        %}
        
    end
end

% Aggregate plot of extracted features across conditions
%{
figure(fig)
hold on
plot(mean(rms_acc1, 1), '-o', 'DisplayName', 'RMS Acc1');
xlabel('Condition');
ylabel('RMS Value');
title('Mean RMS Value Across Conditions');
legend();
fig = fig + 1;

figure(fig)
hold on
plot(mean(peak2peak_acc1, 1), '-o', 'DisplayName', 'Peak-to-Peak Acc1');
xlabel('Condition');
ylabel('Peak-to-Peak Value');
title('Mean Peak-to-Peak Value Across Conditions');
legend();
fig = fig + 1;

figure(fig)
hold on
plot(mean(kurtosis_acc1, 1), '-o', 'DisplayName', 'Kurtosis Acc1');
xlabel('Condition');
ylabel('Kurtosis');
title('Mean Kurtosis Across Conditions');
legend();
fig = fig + 1;
%}

%% 1: Set file path, importing data, and FFT
% Define the paths to the datasets
foldertest1 = 'G:\My Drive\Courses\Industry AI\Industry AI - Group Project\Final Project\Project 2\Testing_DataSet\Test_45Hz_HighLoad';
foldertest2 = 'G:\My Drive\Courses\Industry AI\Industry AI - Group Project\Final Project\Project 2\Testing_DataSet\Test_45Hz_LightLoad';
foldertest3 = 'G:\My Drive\Courses\Industry AI\Industry AI - Group Project\Final Project\Project 2\Testing_DataSet\Test_50Hz_LightLoad';

% Preallocate storage arrays for features
numConditionsTest = 3;
numFiles = 20; % Adjust based on the number of files in each folder
rms_acc1t = zeros(numFiles, numConditionsTest);
peak2peak_acc1t = zeros(numFiles, numConditionsTest);
kurtosis_acc1t = zeros(numFiles, numConditionsTest);

% Loop through each folder (condition)
for j = 1:numConditionsTest
    
    % Select folder based on condition
    switch j
        case 1
            folder = foldertest1;
            targetf = 45;
        case 2
            folder = foldertest2;
            targetf = 45;
        case 3
            folder = foldertest3;
            targetf = 50;
    end
    
    % List all .mat files in the folder
    filepattern = fullfile(folder, '*.mat');
    textfiles = dir(filepattern);
    
    % Loop through each file in the folder
    for i = 1:length(textfiles)
        % Load the data
        healthyfileName = textfiles(i).name;
        filename = fullfile(textfiles(i).folder, healthyfileName);
        fulldata = load(filename);
        datat = fulldata.Gearbox.Data;
        acc1t = datat(:,1);  % Input accelerometer data
        acc2t = datat(:,2);  % Output accelerometer data
        tacht = datat(:,3);  % Tachometer data
        
        % Time-domain features
        rms_acc1t(i, j) = rms(acc1t);
        rms_ratiot(i, j) = rms(acc2t)/rms(acc1t);
        peak2peak_acc1t(i, j) = max(acc1t) - min(acc1t);
        kurtosis_acc1t(i, j) = kurtosis(acc1t);
        
        % Frequency-domain analysis (FFT and sidebands)
        fft_acc1t = fft(acc1t);
        P1_acc1t = abs(fft_acc1t/N);

        %Amplitude at 1X        
        indices = (f > (targetf - sideband_window)) & (f < (targetf + sideband_window));
        band_frequencies = f(indices);
        band_amplitudes = P1_acc1t(indices);
        [peak_acc1_aux, max_index] = max(band_amplitudes);
        fundamentalf_aux = band_frequencies(max_index);

        peak_acc1t(i,j) = peak_acc1_aux;
        fundamentalft(i,j) = fundamentalf_aux 
    end
end



% Plot RMS for Acc1 and Acc2
figure(fig)
hold on
plot(rms_acc1(:, 1), '-o', 'DisplayName', 'RMS Acc1 45HL');
plot(rms_acc1(:, 2), '-o', 'DisplayName', 'RMS Acc1 45LL');
plot(rms_acc1(:, 3), '-o', 'DisplayName', 'RMS Acc1 50HL');
plot(rms_acc1(:, 4), '-o', 'DisplayName', 'RMS Acc1 50LL');
plot(rms_acc1(:, 5), '-x', 'DisplayName', 'RMS Faulty 50HL');
%plot(rms_acc1t(:, 1), '-*', 'DisplayName', 'TEST - RMS Acc1 45HL');
%plot(rms_acc1t(:, 2), '-*', 'DisplayName', 'TEST - RMS Acc1 45LL');
%plot(rms_acc1t(:, 3), '-*', 'DisplayName', 'TEST - RMS Acc1 50LL');
xlabel('File Index');
ylabel('RMS Value');
ylim([0 1.6]);
title('RMS of Acc1 Across Files');
legend();
fig = fig + 1;

figure(fig)
hold on
%plot(rms_acc1(:, 1), '-o', 'DisplayName', 'RMS Acc1 45HL');
%plot(rms_acc1(:, 2), '-o', 'DisplayName', 'RMS Acc1 45LL');
%plot(rms_acc1(:, 3), '-o', 'DisplayName', 'RMS Acc1 50HL');
%plot(rms_acc1(:, 4), '-o', 'DisplayName', 'RMS Acc1 50LL');
%plot(rms_acc1(:, 5), '-x', 'DisplayName', 'RMS Faulty 50HL');
plot(rms_acc1t(:, 1), '-*', 'DisplayName', 'TEST - RMS Acc1 45HL');
plot(rms_acc1t(:, 2), '-*', 'DisplayName', 'TEST - RMS Acc1 45LL');
plot(rms_acc1t(:, 3), '-*', 'DisplayName', 'TEST - RMS Acc1 50LL');
xlabel('File Index');
ylabel('RMS Value');
ylim([0 1.6]);
title('RMS of Acc1 Across Files');
legend();
fig = fig + 1;







% Plot Peak-to-Peak for Acc1 and Acc2
figure(fig)
hold on
plot(peak2peak_acc1(:, 1), '-o', 'DisplayName', 'Peak-to-Peak Acc1 45HL');
plot(peak2peak_acc1(:, 2), '-o', 'DisplayName', 'Peak-to-Peak Acc1 45LL');
plot(peak2peak_acc1(:, 3), '-o', 'DisplayName', 'Peak-to-Peak Acc1 50HL');
plot(peak2peak_acc1(:, 4), '-o', 'DisplayName', 'Peak-to-Peak Acc1 50LL');
plot(peak2peak_acc1(:, 5), '-x', 'DisplayName', 'Peak-to-Peak Faulty 50HL');
%plot(peak2peak_acc1t(:, 1), '-*', 'DisplayName', 'TEST - P2P Acc1 45HL');
%plot(peak2peak_acc1t(:, 2), '-*', 'DisplayName', 'TEST - P2P Acc1 45LL');
%plot(peak2peak_acc1t(:, 3), '-*', 'DisplayName', 'TEST - P2P Acc1 50LL');
xlabel('File Index');
ylabel('Peak-to-Peak Value');
ylim([0 30]);
title('Peak-to-Peak of Acc1 Across Files');
legend();
fig = fig + 1

figure(fig)
hold on
%plot(peak2peak_acc1(:, 1), '-o', 'DisplayName', 'Peak-to-Peak Acc1 45HL');
%plot(peak2peak_acc1(:, 2), '-o', 'DisplayName', 'Peak-to-Peak Acc1 45LL');
%plot(peak2peak_acc1(:, 3), '-o', 'DisplayName', 'Peak-to-Peak Acc1 50HL');
%plot(peak2peak_acc1(:, 4), '-o', 'DisplayName', 'Peak-to-Peak Acc1 50LL');
%plot(peak2peak_acc1(:, 5), '-x', 'DisplayName', 'Peak-to-Peak Faulty 50HL');
plot(peak2peak_acc1t(:, 1), '-*', 'DisplayName', 'TEST - P2P Acc1 45HL');
plot(peak2peak_acc1t(:, 2), '-*', 'DisplayName', 'TEST - P2P Acc1 45LL');
plot(peak2peak_acc1t(:, 3), '-*', 'DisplayName', 'TEST - P2P Acc1 50LL');
xlabel('File Index');
ylabel('Peak-to-Peak Value');
ylim([0 30]);
title('Peak-to-Peak of Acc1 Across Files');
legend();
fig = fig + 1;

% Plot Kurtosis for Acc1 and Acc2
figure(fig)
hold on
plot(kurtosis_acc1(:, 1), '-o', 'DisplayName', 'Kurtosis Acc1 45HL');
plot(kurtosis_acc1(:, 2), '-o', 'DisplayName', 'Kurtosis Acc1 45LL');
plot(kurtosis_acc1(:, 3), '-o', 'DisplayName', 'Kurtosis Acc1 50HL');
plot(kurtosis_acc1(:, 4), '-o', 'DisplayName', 'Kurtosis Acc1 50LL');
plot(kurtosis_acc1(:, 5), '-x', 'DisplayName', 'Kurtosis Faulty 50HL');
%plot(kurtosis_acc1t(:, 1), '-*', 'DisplayName', 'TEST - Kurtosis Acc1 45HL');
%plot(kurtosis_acc1t(:, 2), '-*', 'DisplayName', 'TEST - Kurtosis Acc1 45LL');
%plot(kurtosis_acc1t(:, 3), '-*', 'DisplayName', 'TEST - Kurtosis Acc1 50LL');
xlabel('File Index');
ylabel('Kurtosis');
ylim([0 11]);
title('Kurtosis of Acc1 Across Files');
legend();
fig = fig + 1;

figure(fig)
hold on
%plot(kurtosis_acc1(:, 1), '-o', 'DisplayName', 'Kurtosis Acc1 45HL');
%plot(kurtosis_acc1(:, 2), '-o', 'DisplayName', 'Kurtosis Acc1 45LL');
%plot(kurtosis_acc1(:, 3), '-o', 'DisplayName', 'Kurtosis Acc1 50HL');
%plot(kurtosis_acc1(:, 4), '-o', 'DisplayName', 'Kurtosis Acc1 50LL');
%plot(kurtosis_acc1(:, 5), '-x', 'DisplayName', 'Kurtosis Faulty 50HL');
plot(kurtosis_acc1t(:, 1), '-*', 'DisplayName', 'TEST - Kurtosis Acc1 45HL');
plot(kurtosis_acc1t(:, 2), '-*', 'DisplayName', 'TEST - Kurtosis Acc1 45LL');
plot(kurtosis_acc1t(:, 3), '-*', 'DisplayName', 'TEST - Kurtosis Acc1 50LL');
xlabel('File Index');
ylabel('Kurtosis');
ylim([0 11]);
title('Kurtosis of Acc1 Across Files');
legend();
fig = fig + 1;

% Plot peak for Acc1
figure(fig)
hold on
plot(peak_acc1(:, 1), '-o', 'DisplayName', '1X Amp Acc1 45HL');
plot(peak_acc1(:, 2), '-o', 'DisplayName', '1X Amp Acc1 45LL');
plot(peak_acc1(:, 3), '-o', 'DisplayName', '1X Amp Acc1 50HL');
plot(peak_acc1(:, 4), '-o', 'DisplayName', '1X Amp Acc1 50LL');
plot(peak_acc1(:, 5), '-x', 'DisplayName', '1X Amp Faulty 50HL');
%plot(peak_acc1t(:, 1), '-*', 'DisplayName', 'TEST - 1X Amp Acc1 45HL');
%plot(peak_acc1t(:, 2), '-*', 'DisplayName', 'TEST - 1X Amp Acc1 45LL');
%plot(peak_acc1t(:, 3), '-*', 'DisplayName', 'TEST - 1X Amp Acc1 50LL');
xlabel('File Index');
ylabel('Amplitude at 1X');
ylim([0 0.1]);
title('Amplitude of Acc1 Across Files');
legend();
fig = fig + 1

figure(fig)
hold on
%plot(peak_acc1(:, 1), '-o', 'DisplayName', '1X Amp Acc1 45HL');
%plot(peak_acc1(:, 2), '-o', 'DisplayName', '1X Amp Acc1 45LL');
%plot(peak_acc1(:, 3), '-o', 'DisplayName', '1X Amp Acc1 50HL');
%plot(peak_acc1(:, 4), '-o', 'DisplayName', '1X Amp Acc1 50LL');
%plot(peak_acc1(:, 5), '-x', 'DisplayName', '1X Amp Faulty 50HL');
plot(peak_acc1t(:, 1), '-*', 'DisplayName', 'TEST - 1X Amp Acc1 45HL');
plot(peak_acc1t(:, 2), '-*', 'DisplayName', 'TEST - 1X Amp Acc1 45LL');
plot(peak_acc1t(:, 3), '-*', 'DisplayName', 'TEST - 1X Amp Acc1 50LL');
xlabel('File Index');
ylabel('Amplitude at 1X');
ylim([0 0.1]);
title('Amplitude of Acc1 Across Files');
legend();
fig = fig + 1;

% Save extracted feature data
save('extracted_features.mat', 'rms_acc1', 'peak2peak_acc1', 'kurtosis_acc1');


O1 = [rms_acc1(:,1) peak2peak_acc1(:,1) kurtosis_acc1(:,1) fundamentalf(:,1)];
O2 = [rms_acc1(:,2) peak2peak_acc1(:,2) kurtosis_acc1(:,2) fundamentalf(:,2)];
O3 = [rms_acc1(:,3) peak2peak_acc1(:,3) kurtosis_acc1(:,3) fundamentalf(:,3)];
O4 = [rms_acc1(:,4) peak2peak_acc1(:,4) kurtosis_acc1(:,4) fundamentalf(:,4)];
O5 = [rms_acc1(:,5) peak2peak_acc1(:,5) kurtosis_acc1(:,5) fundamentalf(:,5)];


outputfile1 = 'features_baseline_45Hz_HighLoad.dat';
outputfile2 = 'features_baseline_45Hz_LightLoad.dat';
outputfile3 = 'features_baseline_50Hz_HighLoad.dat';
outputfile4 = 'features_baseline_50Hz_LightLoad.dat';
outputfile5 = 'features_defective_baseline_50Hz_HighLoad.dat';

%fprintf(fileID2,'rms \t p2p \t kurt \t ff \n');

fileID1 = fopen(outputfile1,'w');
[nRows, nCols] = size(O1);
for row = 1:nRows
    fprintf(fileID1, '%.6f\t ', O1(row, :)); 
    fprintf(fileID1, '\n'); 
end
fclose(fileID1);

fileID2 = fopen(outputfile2,'w');
[nRows, nCols] = size(O2);
for row = 1:nRows
    fprintf(fileID2, '%.6f\t ', O2(row, :)); 
    fprintf(fileID2, '\n'); 
end
fclose(fileID2);

fileID3 = fopen(outputfile3,'w');
[nRows, nCols] = size(O3);
for row = 1:nRows
    fprintf(fileID3, '%.6f\t ', O3(row, :)); 
    fprintf(fileID3, '\n'); 
end
fclose(fileID3);

fileID4 = fopen(outputfile4,'w');
[nRows, nCols] = size(O4);
for row = 1:nRows
    fprintf(fileID4, '%.6f\t ', O4(row, :)); 
    fprintf(fileID4, '\n'); 
end
fclose(fileID4);

fileID5 = fopen(outputfile5,'w');
[nRows, nCols] = size(O5);
for row = 1:nRows
    fprintf(fileID5, '%.6f\t ', O5(row, :)); 
    fprintf(fileID5, '\n'); 
end
fclose(fileID5);


%%-----------------------------------------------------------------------------------------------


O1t = [rms_acc1t(:,1) peak2peak_acc1t(:,1) kurtosis_acc1t(:,1) fundamentalft(:,1)];
O2t = [rms_acc1t(:,2) peak2peak_acc1t(:,2) kurtosis_acc1t(:,2) fundamentalft(:,2)];
O3t = [rms_acc1t(:,3) peak2peak_acc1t(:,3) kurtosis_acc1t(:,3) fundamentalft(:,3)];



outputfile1t = 'features_testing_45Hz_HighLoad.dat';
outputfile2t = 'features_testing_45Hz_LightLoad.dat';
outputfile3t = 'features_testing_50Hz_LightLoad.dat';

%fprintf(fileID2,'rms \t p2p \t kurt \t ff \n');

fileID1t = fopen(outputfile1t,'w');
[nRows, nCols] = size(O1t);
for row = 1:nRows
    fprintf(fileID1t, '%.6f\t ', O1t(row, :)); 
    fprintf(fileID1t, '\n'); 
end
fclose(fileID1t);

fileID2t = fopen(outputfile2t,'w');
[nRows, nCols] = size(O2t);
for row = 1:nRows
    fprintf(fileID2t, '%.6f\t ', O2t(row, :)); 
    fprintf(fileID2t, '\n'); 
end
fclose(fileID2t);

fileID3t = fopen(outputfile3t,'w');
[nRows, nCols] = size(O3t);
for row = 1:nRows
    fprintf(fileID3t, '%.6f\t ', O3t(row, :)); 
    fprintf(fileID3t, '\n'); 
end
fclose(fileID3t);

