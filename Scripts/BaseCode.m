clc;
clear;
close all;

% Find Project Directory
% Assumes script is in a 'scripts' folder below the top project directory
% and data is not in duplicate folders ie. "Training/Faulty" not
% "Training/Training/Faulty"
if ispc
    delimeter = "\";
else
    delimeter = "/";
end
scriptPath = split(mfilename('fullpath'),delimeter);
projectPath = join(scriptPath(1:end-2,:),delimeter);
projectPath = projectPath{1};

directoryF=join([projectPath, "Training","Faulty",""],delimeter);
structuretrain=struct([]);
structuretrain = createstructure(directoryF,structuretrain,0);

directoryH=join([projectPath, "Training","Healthy",""],delimeter);
structuretrain = createstructure(directoryH,structuretrain,1);

structuretest=struct([]);
directoryTe=join([projectPath,"Testing",""],delimeter);
structuretest = createstructure(directoryTe,structuretest,-1);

directorys=join([projectPath,"Results",""],delimeter);
%plotcurves(structuretrain, directorys)
%plotcurves(structuretest, directorys)

FMTrain=[[structuretrain.magnear20]',[structuretrain.stdv20]',[structuretrain.magnear40]',[structuretrain.stdv40]'];
NamesTrain=createnamevec(structuretrain);
HorFVTrain=[structuretrain.HorF]';


FMTest=[[structuretest.magnear20]',[structuretest.magnear40]',[structuretest.stdv20]',[structuretest.stdv40]'];
NamesTest=createnamevec(structuretest);

% Train Log Regression
linCoef = glmfit([[structuretrain.magnear20]',[structuretrain.magnear40]'], [structuretrain.HorF]', 'binomial','link','logit');
figure(1)
figTitle = 'Training Data with Mag. 21Hz and Mag. 42Hz';
trainingResults.twoVars = plotLogRegression([[structuretrain.magnear20]',[structuretrain.magnear40]'], linCoef, figTitle);

figure(2)
figTitle = ('Testing Data with Mag. 21Hz and Mag. 42Hz');
testingResults.twoVars = plotLogRegression([[structuretest.magnear20]',[structuretest.magnear40]'], linCoef, figTitle);

linCoef = glmfit([structuretrain.magnear20], [structuretrain.HorF]', 'binomial','link','logit');
figure(3)
testingResults.mag20 = plotLogRegression([structuretest.magnear20], linCoef);
title('Testing Data with Mag. 21Hz')

figure(4)
trainingResults.mag20 = plotLogRegression([structuretrain.magnear20], linCoef);
title('Training Data with Mag. 21Hz')

linCoef = glmfit([structuretrain.magnear40], [structuretrain.HorF]', 'binomial','link','logit');
figure(5)
testingResults.mag40 = plotLogRegression([structuretest.magnear40], linCoef);
title('Testing Data with Mag. 42Hz')

figure(6)
trainingResults.mag40 = plotLogRegression([structuretrain.magnear40], linCoef);
title('Training Data with Mag. 42Hz')

function [names] = createnamevec(structure)
    names=string.empty;
    for i = 1:length(structure)
        names(i)=structure(i).name;
    end
    names=names';
end

function [structure] = plotcurves(structure, directorys)
    fignumb =  length(findobj('type','figure'));
    for i = 1:length(structure)
        [~,name,~] = fileparts(structure(i).name);
        figure(i+fignumb)
        subplot(2,1,1)
        plot(structure(i).time,structure(i).acc)
        title(name)
        xlabel('Time')
        ylabel('Acc')
        subplot(2,1,2)
        plot(structure(i).freq,structure(i).mag,'DisplayName','FFT')
        hold on
        plot(structure(i).freqnear20, structure(i).magnear20, 'r.', 'LineWidth', 2, 'MarkerSize', 25, 'DisplayName','Max Near 20');
        hold on
        plot(structure(i).freqnear40, structure(i).magnear40, 'g.', 'LineWidth', 2, 'MarkerSize', 25,'DisplayName','Max Near 60');
        legend;
        xlabel('freq(Hz)')
        xlim([0 100])
        ylabel('Mag')
        hold off
        saveas(gcf,strcat(directorys,name,'.pdf'))
    end
end

function failureProb = plotLogRegression(predictData, linCoefs, varargin)
z = @(x)(linCoefs(1) + (x*linCoefs(2:end)));
zFinal = @(x)(1 ./(1+exp(-(z(x)))));   
failureProb = zFinal(predictData);
%plot(predictData,failureProb,'*');
if size(predictData,1) < size(predictData,2)
    predictData = predictData';
end
numVars = size(predictData,2);

for k = 1:numVars
    funcMin(k) = min(predictData(:,k));
    funcMax(k) = max(predictData(:,k));
    funcSamplePoints(:,k) = funcMin(k):(funcMax(k)-funcMin(k))/1000:funcMax(k);
    funcQuarters(:,k) = funcMin(k):(funcMax(k)-funcMin(k))/4:funcMax(k);
end
if numVars > 1
    for k = 1:numVars
        subplot(numVars,1,k)
        legendLabel = string.empty(5,0);
        for m = 1:5
            marginSamplePredictors = ones(size(funcSamplePoints,1),numVars);
            for n = 1:numVars
                if n == k
                    marginSamplePredictors(:,n) = funcSamplePoints(:,k);
                else
                    marginSamplePredictors(:,n) = funcQuarters(m,n)*marginSamplePredictors(:,n);
                end
            end
            marginSampleResults = zFinal(marginSamplePredictors);
            plot(funcSamplePoints(:,k),marginSampleResults)
            if m ==1
                hold on
            end
            if k == 1
                legendLabel(m) = sprintf('42Hz Magnitude of %0.3f', funcQuarters(m,2));
            elseif k ==2
                legendLabel(m) = sprintf('21Hz Magnitude of %0.3f', funcQuarters(m,1));
            end
        end
        hold off
        if k == 1
            title(varargin{1})
            xlabel('Magnitude of Acceleration at 21Hz')
        elseif k==2
            xlabel('Magnitude of Acceleration at 42Hz')
        end
        ylabel('Probability of Healthy Spindle')
        legend(legendLabel);
    end
%     surfDim = size(funcSamplePoints,1);
%     sampSurface = zeros(surfDim);
%     for k = 1:surfDim
%         for m = 1:surfDim
%             sampSurface(k,m) = zFinal([funcSamplePoints(k,1),funcSamplePoints(m,2)]);
%         end
%     end
%     surf(funcSamplePoints(:,2),funcSamplePoints(:,1),sampSurface)
%     colormap(pink)
%     shading interp
%     xlabel('Magnitude of Acceleration at 40Hz');
%     ylabel('Magnitude of Acceleration at 20Hz');
%     zlabel('Probability of Healthy Spindle');
    %subplot(2,1,2)
    %plot
elseif numVars == 1
    plot(predictData,failureProb,'*',funcSamplePoints(:,1),zFinal(funcSamplePoints(:,1)),'-');
    xlabel('Magnitude of Acceleration at 20Hz');
    ylabel('Probability of Healthy Spindle');
    legend('Data Samples','Regression Curve')
end

%funcMin = min(predictData);
%funcMax = max(predictData);
%funcSamplePoints = funcMin:(funcMax-funcMin)/1000:funcMax;

%hold on

%hold off
end

function [structure] = createstructure(directory,structure,HorF)
    files=dir(directory);
    files=files(~ismember({files.name},{'.','..'}));
    j=1;
    for i = length(structure)+1:length(structure)+length(files)
        structure(i).name=strcat(directory,files(j).name);
        [structure(i).time,structure(i).acc]=Opentxtfile(structure(i).name);
        [structure(i).freq,structure(i).mag]=fftfull(structure(i).acc);
        structure(i).HorF=HorF;
        [structure(i).freqnear20,structure(i).magnear20] = findmax(structure(i).freq,structure(i).mag,20*0.8,20*1.2);
        [structure(i).freqnear40,structure(i).magnear40] = findmax(structure(i).freq,structure(i).mag,40*0.8,40*1.2);
        structure(i).stdv20=stdevr(structure(i).freq,structure(i).mag,structure(i).freqnear20);
        structure(i).stdv40=stdevr(structure(i).freq,structure(i).mag,structure(i).freqnear40);
        j=j+1;
    end
end

function [freq,mag] = fftfull(acc)
    lenacc=length(acc);
    Fs=2560;
    nexp = 2^nextpow2(lenacc);
    mag = fft(acc,nexp)/lenacc;
    freq = (Fs/2*linspace(0,1,nexp/2+1))';
    mag=(2*abs(mag(1:nexp/2+1)));
end

function [time,acc] = Opentxtfile(file)
    fileID = fopen(file,'r');
    formatSpec = '%f';
    for i = 1:5
        fgetl(fileID);
    end
    acc = fscanf(fileID,formatSpec);
    fclose(fileID);
    time=zeros(length(acc),1);
    for i=2:length(time)
        time(i)=time(i-1)+(1/2560);
    end
end

function [freqmax,magmax] = findmax(freq,mag,mintarget,maxtarget)
    [~,idmax]=min(abs(freq-maxtarget));
    [~,idmin]=min(abs(freq-mintarget));
    [magmax,idf]=max(mag(idmin:idmax));
    freqmax=freq(idf+idmin);
end

function stdevf = stdevr(freq,mag,freqt)
    [~,idmax]=min(abs(freq-(freqt*1.2)));
    [~,idmin]=min(abs(freq-(freqt*0.8)));
    stdevf=std(mag(idmin:idmax));
end