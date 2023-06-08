
slicesILM = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\ILM\slicesILM_08_TRK_OD.mat').slicesILM;
%slicesILM = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\ILM\slicesILM_04_BIM_OD.mat').slicesILM;
%slicesILM = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\ILM\slicesILM_02-DEA_OD.mat').slicesILM;
%slicesILM = load('C:\Users\knob\Documents\MATLAB\projet_ocd\Segmentations\ILM\slicesILM_01-CABONS OD.mat').slicesILM;

for sliceILM=slicesILM
    sliceILM = sliceILM{1};
    %plot(sliceILM(2,:), max(sliceILM(1,:)) - sliceILM(1,:));
    plot(sliceILM(2,:), sliceILM(1,:));
    hold on;
end
