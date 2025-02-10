clear
clc

%% SOM-MQE demo code
% Created by Dai-Yan Ji
% University of Maryland-College Park
% 2024.03.02
%
% somtoolbox is required
% more information abuot the toolbox: http://www.cis.hut.fi/somtoolbox/

%%
% Load the data
  A = load('trainingDataFeatures.txt');
  B = load('testingDataFeatures.txt')
  
%% Training of SOM with Normal condition data

%TrainData=A(1:62;125:186;249:310,:)
TrainData=[A(1:62;:); A(125:186,:); A(249:310,:)];
TestData=[A(63:124,:); A(187:248,:)];

sM=som_make(TrainData);


%% Calculate the MQE values for the testing data set
S=size(TestData);
S=S(1);
for ii=1:S
    qe=som_quality(sM,TestData(ii,:)); % calculate MQE value for each sample
    MQEt(ii)=qe;
end

MQEtn=(1-(MQEt)./(max(MQEt))); % normalize MQE
MQEtn=MQEtn';

%% Plot the calculated MQE values 
% observe the difference between normal condition and faluty conditions
hold on
plot(MQEtn,'-*', 'DisplayName', 'Faulty - 50HL');
legend();
ylim([0 1]);
xlabel('Data file No.');
 ylabel('Confidence value (MQE)');
 title('Health Assessment Plot');
