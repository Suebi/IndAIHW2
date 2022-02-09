clc;
clear;
close all;
directoryF='\\clusterfsnew.ceas1.uc.edu\students\perlitda\My Documents\Hw2\Training\Training\Faulty\';
HorF=0;
structure=struct([]);
structure = createstructure(directoryF,structure,HorF);

directoryH='\\clusterfsnew.ceas1.uc.edu\students\perlitda\My Documents\Hw2\Training\Training\Healthy\';
HorF=1;
structure = createstructure(directoryH,structure,HorF);

directorys='\\clusterfsnew.ceas1.uc.edu\students\perlitda\My Documents\Hw2\results\';

for i = 1:length(structure)
    [pathstr,name,ext] = fileparts(structure(i).name);
    figure(i)
    subplot(2,1,1)
    plot(structure(i).time,structure(i).acc)
    title(name)
    xlabel('Time')
    ylabel('Acc')
    subplot(2,1,2)
    plot(structure(i).freq,structure(i).mag)
    xlabel('freq(Hz)')
    xlim([0 100])
    ylabel('Mag')
    saveas(gcf,strcat(directorys,name,'.pdf'))
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
        j=j+1;
    end
end

function [freq,mag] = fftfull(acc)
    L=length(acc);
    Fs=2560;
    NFFT = 2^nextpow2(L); % Next power of 2 from length of y
    mag = fft(acc,NFFT)/L;
    freq = (Fs/2*linspace(0,1,NFFT/2+1))';
    mag=(2*abs(mag(1:NFFT/2+1)));
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