
close all

load('initial_values.mat')
indices = find(y);
values = y(indices);
diff_values = unique(y);

Tr1_i = find(mod(y,2) ~= 0);
Tr1 = zeros(1, length(y));
Tr1(Tr1_i) = 1;
stairs(Tr1(100000:113000))


DRI2 =  find(y == 2);
DRI6 =  find(y == 6);
DRI10 =  find(y == 10);
DRI11 =  find(y == 11);
DRI18 =  find(y == 18);
DRI66 =  find(y == 66);

% VSI = [VSI8, VSI9, VSI10, VSI11];
len_DRI = length(DRI2) + length(DRI6) + length(DRI10) + length(DRI11) + length(DRI18) + length(DRI66) - 22;
DRI_i = zeros(1,len_DRI);
DRI_i(1:length(DRI2)) = DRI2;
DRI_i((length(DRI2)+1) : (length(DRI2) + length(DRI6))) = DRI6;
DRI_i((length(DRI6)+1) : (length(DRI6) + length(DRI10))) = DRI10;
DRI_i((length(DRI10)+1) : (length(DRI10) + length(DRI11))) = DRI11;
DRI_i((length(DRI11)+1) : (length(DRI11) + length(DRI18))) = DRI18;
DRI_i((length(DRI18)+1) : (length(DRI18) + length(DRI66))) = DRI66;

DRI = zeros(1, length(y));
DRI(DRI_i) = 1;
 figure 
 stairs(DRI)


DSI_i = find(y == 4);
DSI = zeros(1, length(y));
DSI(DSI_i) = 1;
figure
stairs(DSI)


VSI8 =  find(y == 8);
VSI9 =  find(y == 9);
VSI10 =  find(y == 10);
VSI11 =  find(y == 11);

% VSI = [VSI8, VSI9, VSI10, VSI11];
len_VSI = length(VSI8) + length(VSI9) + length(VSI10) + length(VSI11)-7;
VSI_i = zeros(1,len_VSI);
VSI_i(1:length(VSI8)) = VSI8;
VSI_i((length(VSI8)+1) : (length(VSI8) + length(VSI9))) = VSI9;
VSI_i((length(VSI9)+1) : (length(VSI9) + length(VSI10))) = VSI10;
VSI_i((length(VSI10)+1) : (length(VSI10) + length(VSI11))) = VSI11;

VSI = zeros(1, length(y));
VSI(VSI_i) = 1;
 figure 
 stairs(VSI)
 
 
C216 =  find(y == 16);
C217 =  find(y == 17);
C218 =  find(y == 18);

len_C2 = length(C216) + length(C217) + length(C218) - 7;
C2_i = zeros(1,len_C2);
C2_i(1:length(C216)) = C216;
C2_i((length(C216)+1) : (length(C216) + length(C217))) = C217;
C2_i((length(C217)+1) : (length(C217) + length(C218))) = C218;

C2 = zeros(1, length(y));
C2(C2_i) = 1;
 figure 
 stairs(C2)
 
 
 %%%%VFN 
VFN32  =  find(y == 32);
VFN33  =  find(y == 33);

len_VFN = length(VFN32) + length(VFN33);
VFN_i = zeros(1,len_VFN);
VFN_i(1:length(VFN32)) = VFN32;
VFN_i((length(VFN32)+1) : (length(VFN32) + length(VFN33))) = VFN33;

VFN = zeros(1, length(y));
VFN(VFN_i) = 1;
 figure 
 stairs(VFN)
 
 
DFN64 =  find(y == 64);
DFN65 =  find(y == 65);
DFN66 =  find(y == 66);
DFN67 =  find(y == 67);

% VSI = [VSI8, VSI9, VSI10, VSI11];
len_DFN = length(DFN64) + length(DFN65) + length(DFN66) + length(DFN67)-11;
DFN_i = zeros(1,len_DFN);
DFN_i(1:length(DFN64)) = DFN64;
DFN_i((length(DFN64)+1) : (length(DFN64) + length(DFN65))) = DFN65;
DFN_i((length(DFN65)+1) : (length(DFN65) + length(DFN66))) = DFN66;
DFN_i((length(DFN66)+1) : (length(DFN66) + length(DFN67))) = DFN67;

DFN = zeros(1, length(y));
DFN(DFN_i) = 1;
 figure 
 stairs(DFN)
 
 
 
% Get rid of extra spikes
Tr1i = [];
j = 1;
for i = 1:2:length(Tr1_i)
    Tr1i(j) = Tr1_i(i);
    j = j+1;
end

DRIi = [];
j = 1;
for i = 1:2:length(DRI_i)
    DRIi(j) = DRI_i(i);
    j = j+1;
end
 
DSIi = [];
j = 1;
for i = 1:2:length(DSI_i)
    DSIi(j) = DSI_i(i);
    j = j+1;
end

VSIi = [];
j = 1;
for i = 1:2:length(VSI_i)
    VSIi(j) = VSI_i(i);
    j = j+1;
end

C2i = [];
j = 1;
for i = 1:2:length(C2_i)
    C2i(j) = C2_i(i);
    j = j+1;
end

VFNi = [];
j = 1;
for i = 1:2:length(VFN_i)
    VFNi(j) = VFN_i(i);
    j = j+1;
end

DFNi = [];
j = 1;
for i = 1:2:length(DFN_i)
    DFNi(j) = DFN_i(i);
    j = j+1;
end

% Histogram

% Tr1, DRI, DSI, C2, VSI, DFN, VFN
num_spikes = [length(Tr1i), length(DRIi), length(DSIi), length(C2i), length(VSIi), length(DFNi), length(VFNi)];
figure
bar(num_spikes)


spikes = find(y > 0);
% spikes1s = zeros(1, length(y));
% spikes1s(spikes) = 1;
% figure
% hist(spikes1s)
figure
[N, Edges] = histcounts(spikes, 10);
histogram(spikes, Edges)


%Peri-Stimulus Time Histogram
ly = floor(length(y)/12);
data = zeros(12, ly);
num_spikes = zeros(1,12);
j = 1;
for i= 1:12
    data(i,:) = y(j:j+ly-1);
    j = j + ly;
    sp = find(data(i,:) > 0);
    num_spikes(i) = length(sp);
end
figure
bar(num_spikes)

% Raster Chart
figure
tiledlayout(7,1)
nexttile
for i = 1:length(Tr1i)
    line([Tr1i(i) Tr1i(i)], [0 1])
    hold on
end

nexttile
for i = 1:length(DRIi)
    line([DRIi(i) DRIi(i)], [0 1])
    hold on
end

nexttile
for i = 1:length(DSIi)
    line([DSIi(i) DSIi(i)], [0 1])
    hold on
end

nexttile
for i = 1:length(C2i)
    line([C2i(i) C2i(i)], [0 1])
    hold on
end

nexttile
for i = 1:length(VSIi)
    line([VSIi(i) VSIi(i)], [0 1])
    hold on
end

nexttile
for i = 1:length(DFNi)
    line([DFNi(i) DFNi(i)], [0 1])
    hold on
end

nexttile
for i = 1:length(VFNi)
    line([VFNi(i) VFNi(i)], [0 1])
    hold on
end
 