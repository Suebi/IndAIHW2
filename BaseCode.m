clc;
clear;
close all;
dir='/Users/nbosticco/Desktop/Nick/AI/Homework 2/Testing/';
[file,path] = uigetfile({'*.txt'},'Pick a File',dir);
[time,acc]=Opentxtfile(strcat(path,file));
[freq,mag] = fftfull(acc);

figure(1)
plot(time,acc)
xlabel('time')
ylabel('Acc')

figure(2)
plot(freq,mag)
xlabel('freq(Hz)')
ylabel('Mag')