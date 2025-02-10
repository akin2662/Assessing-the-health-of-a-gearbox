B_labels = [repmat({'H'},60,1)];
B_true_labels = [repmat({'H'},60,1)];

for i=1:17
    B_labels(31+i) = {'F'};
end

for i=1:12
    B_true_labels(48+i) = {'F'};
    B_labels(48+i) = {'F'};
end

B_labels(59) = {'H'};
B_labels(60) = {'H'};




figure;
confusionchart(B_true_labels, B_labels, 'Normalization', 'row-normalized');
title('Confusion Matrix for Fault Classification');