P_train = P_train_std; Val.P = Val_std.P; %%% Use this line if you use STD preprocessing on the data. IMPORTANT: Run preprocess.m first 

num_iterations = 10;
Missclassification_rate = zeros(num_iterations,1);
mse_performance = zeros(num_iterations,1);
num_hidden_layers = 1;
for i = 10:10:110
    [net] = newff(minmax(P_train),[10 1],{'tansig','tansig'},'trainlm');
    net.trainParam.epochs =200;
    net.trainParam.min_grad=1e-20;
    net.trainParam.max_fail = i;
    net.performFcn = 'mse';  % Mean squared error
    
    net.divideFcn = 'dividerand';  % Divide data randomly
    net.divideMode = 'sample';  % Divide up every sample
    net.divideParam.trainRatio = 70/100;
    net.divideParam.valRatio = 30/100;
    net.divideParam.testRatio = 0/100;
    
    
    %train
    [net,tr] = train(net,P_train,T_train,[],[],Val);
    [fields,N] = size(T_test);
    neuralnetscore = sign(sim(net,Val.P));
    
    outputs = net(P_train);
    errors = gsubtract(T_train,outputs);

    %test
    test_inputs = Val.P;
    test_outputs = net(test_inputs);

    
    Missclassification_rate((i-10)/10+1,1) = sum(0.5*abs(T_test - neuralnetscore))/N;
    mse_performance((i-10)/10+1,1) = perform(net,T_test,test_outputs);
    
    %plot and save the performance figure
    name = ['Trainlmmaxfail\performance_',num2str(num_hidden_layers),'_',num2str(num_neurons)];
    h=figure;
    plotperform(tr);
    saveas(h,name,'jpg');
    
    %plot and save trainstate
    name = ['Trainlmmaxfail\plottrainstate',num2str(num_hidden_layers),'_',num2str(num_neurons)];
    h=figure;
    plottrainstate(tr);
    saveas(h,name,'jpg');
    
    %plot and save regression
    name = ['Trainlmmaxfail\plotregression',num2str(num_hidden_layers),'_',num2str(num_neurons)];
    h=figure;
    plotregression(T_train,outputs);
    saveas(h,name,'jpg');
    
    
    %plot and save histogram
    name = ['Trainlmmaxfail\plothistogram',num2str(num_hidden_layers),'_',num2str(num_neurons)];
    h=figure;
    ploterrhist(errors);
    saveas(h,name,'jpg');
    
end
x = zeros(num_iterations,1);
for i = 1:num_iterations
    x(i,1) = i;
end

%plotting misclassification rate
name = ['Trainlmmaxfail\misclassification_rate'];
h=figure;
plot(x,Missclassification_rate);
saveas(h,name,'jpg');


%plotting misclassification rate
h=figure;
plot(x,mse_performance);
name = ['Trainlmmaxfail\mseperformance_rate'];
saveas(h,name,'jpg');


%save('Misclassification_rate',Missclassification_rate);