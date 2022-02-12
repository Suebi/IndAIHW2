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

%[1]
FMTrain=[[structuretrain.magnear20]',[structuretrain.stdv20]',[structuretrain.magnear40]',[structuretrain.stdv40]'];
NamesTrain=createnamevec(structuretrain);
HorFVTrain=[structuretrain.HorF]'+1;

B=mnrfit(FMTrain,HorFVTrain);
predtrain=1./(1+exp(-[ones(length(HorFVTrain),1),FMTrain]*B));

FMTest=[[structuretest.magnear20]',[structuretest.stdv20]',[structuretest.magnear40]',[structuretest.stdv40]'];
NamesTest=createnamevec(structuretest);

predtest=1./(1+exp(-[ones(size(FMTest,1),1),FMTest]*B));
plotcurves(structuretest, directorys)
% figure(1)
% plot([structuretrain.magnear20]')
% xlabel('File')
% ylabel('FFT Mag Near First Peak')
% saveas(gcf,strcat(directorys,'FFT Mag Near First Peak','.pdf'))
% figure(2)
% plot([structuretrain.magnear40]')
% xlabel('File')
% ylabel('FFT Mag Near Sec Peak')
% saveas(gcf,strcat(directorys,'FFT Mag Near Sec Peak','.pdf'))
% figure(3)
% plot([structuretrain.stdv20]')
% xlabel('File')
% ylabel('Stdev Near First Peak')
% saveas(gcf,strcat(directorys,'Stdev Near First Peak','.pdf'))
% figure(4)
% plot([structuretrain.stdv40]')
% xlabel('File')
% saveas(gcf,strcat(directorys,'Stdev Near sec Peak','.pdf'))

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
        xlabel('Time (s)')
        ylabel('Acceleration')
        subplot(2,1,2)
        plot(structure(i).freq,structure(i).mag,'DisplayName','FFT')
        hold on
        plot(structure(i).freqnear20, structure(i).magnear20, 'r.', 'LineWidth', 2, 'MarkerSize', 25, 'DisplayName','Max Near 20');
        hold on
        plot(structure(i).freqnear40, structure(i).magnear40, 'g.', 'LineWidth', 2, 'MarkerSize', 25,'DisplayName','Max Near 40');
        legend;
        xlabel('freq(Hz)')
        xlim([0 60])
        %ylim([0 0.03])
        ylabel('Magnitude')
        hold off
        saveas(gcf,strcat(directorys,name,'.jpg'))
    end
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
    %[2]
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

%Ref
%[1] PARISlab@UCLA. Training a Logistic Regression Classification Model with Matlab – Machine Learning for Engineers. 21 May 2020. 11 February 2022.

%[2] MathWorks. fft. 2022. 11 February 2022. <https://www.mathworks.com/help/matlab/ref/fft.html>.

