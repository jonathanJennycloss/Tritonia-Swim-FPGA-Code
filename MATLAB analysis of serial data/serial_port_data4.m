%Run section instead of run
%% Open serial Port
% 1) Serial port open before programing FPGA
s = serialport("COM4", 115200)

%% Collect data from the FPGA
x = read(s,1200000*2,"char");

%% Convert data
y = str2num(x);