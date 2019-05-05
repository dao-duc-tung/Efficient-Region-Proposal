function drawROC(RECALL_ALL,PREC_ALL,FPR_ALL)
figure(10);
plot(FPR_ALL,RECALL_ALL, 'b-');
axis([0 5 0 100]);
title('ROC Curve');
xlabel('False Positive Rate');
ylabel('True Positive Rate');

figure(11);
plot(RECALL_ALL,PREC_ALL, 'r-');
axis([0 100 0 100]);
title('PR Curve');
xlabel('Recall');
ylabel('Precision');

end