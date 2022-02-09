close all;
clc;
clear;

% Get Homework 2 Folder
if ispc
    delimeter = "\";
else
    delimeter = "/";
end
scriptPath = split(mfilename('fullpath'),delimeter);
projectPath = join(scriptPath(1:end-2,:),delimeter);
projectPath = projectPath{1};

% Load healthy training files to get healthy time, acceleration, frequency
% and magnitude data
training_files_healthy = dir(join([projectPath,"Training/Healthy/*.txt"],delimeter));
for i = 1:length(training_files_healthy)
    path_healthy = join([projectPath,"Training/Healthy",training_files_healthy(i).name],delimeter);
    [training_data_healthy_time(:,i),training_data_healthy_acc(:,i)] = Opentxtfile(path_healthy);
    [training_data_healthy_freq(:,i),training_data_healthy_mag(:,i)] = fftfull(training_data_healthy_acc(:,i));
end

% Load faulty training files to get faulty time, acceleration, frequency
% and magnitude data
training_files_faulty = dir(join([projectPath,"Training/Faulty/*.txt"],delimeter));
for i = 1:length(training_files_faulty)
    path_faulty = join([projectPath,"Training/Faulty",training_files_faulty(i).name],delimeter);
    [training_data_faulty_time(:,i),training_data_faulty_acc(:,i)] = Opentxtfile(path_faulty);
    [training_data_faulty_freq(:,i),training_data_faulty_mag(:,i)] = fftfull(training_data_faulty_acc(:,i));
end

% Load testing files to get time, acceleration, frequency
% and magnitude data
testing_files = dir(join([projectPath,"Testing/*.txt"],delimeter));
for i = 1:length(testing_files)
    path_testing = join([projectPath, "Testing",testing_files(i).name],delimeter);
    [testing_data_time(:,i),testing_data_acc(:,i)] = Opentxtfile(path_testing);
    [testing_data_freq(:,i),testing_data_mag(:,i)] = fftfull(testing_data_acc(:,i));
end

% Obtain the maximum magnitude and frequency of maximum magnitude from 10 to 30 Hz for healthy data
for col = 1:size(training_data_healthy_freq,2)
    mag_healthy(col,1) = max(training_data_healthy_mag(257:769,col));
    freq_healthy(col,1) = training_data_healthy_freq(find(training_data_healthy_mag == mag_healthy(col,1)));
end

% Obtain the magnitude at 20 Hz for faulty data
for col = 1:size(training_data_faulty_freq,2)
    mag_faulty(col,1) = max(training_data_faulty_mag(257:769,col));
    freq_faulty(col,1) = training_data_faulty_freq(find(training_data_faulty_mag == mag_faulty(col,1)));
end

% Obtain the magnitude at 20 Hz for testing data
for col = 1:size(testing_data_freq,2)
    mag_testing(col,1) = max(testing_data_mag(257:769,col));
    freq_testing(col,1) = testing_data_freq(find(testing_data_mag == mag_testing(col,1)));
end

healthy_mag_average = mean(mag_healthy);
healthy_mag_std = std(mag_healthy);
healthy_freq_average = mean(freq_healthy);
healthy_freq_std = std(freq_healthy);

faulty_mag_average = mean(mag_faulty);
faulty_mag_std = std(mag_faulty);
faulty_freq_average = mean(freq_faulty);
faulty_freq_std = std(freq_faulty);

disp('healthy_mag_average')
disp(healthy_mag_average)
disp('faulty_mag_average')
disp(faulty_mag_average)

disp('healthy_mag_std')
disp(healthy_mag_std)
disp('faulty_mag_std')
disp(faulty_mag_std)

disp('healthy_freq_average')
disp(healthy_freq_average)
disp('faulty_freq_average')
disp(faulty_freq_average)

disp('healthy_freq_std')
disp(healthy_freq_std)
disp('faulty_freq_std')
disp(faulty_freq_std)

