clear all; close all
clc

addpath('func');
%filename = 'train_10k_long.ffeat';
%filename = 'dev_long.lmscore';
%filename = 'set1.ffeat';
filename = 'sample_data/train_10k_long_all.ffeat';
[fid, message] = fopen(filename);
if fid == -1,
    disp(message);
    disp(filename);
end

outList = [];
uttNum = 1;
str = fgets(fid);
while str ~= -1
    segStr = regexp(str, '\s', 'split');
    
    outList(uttNum).uName = deblank(segStr{1});
    tmpfeat = [];
    begi = 3;
    if deblank(segStr{2}) ~= '[',
        %error('Error !! kaldi file is wrong');
        begi = 2;
    end
    
    for i=begi:size(segStr,2)
        if ~isnan(str2double(segStr{i})),
            tmpfeat = [tmpfeat str2double(segStr{i})];
        end
    end
    outList(uttNum).feat = tmpfeat;
    uttNum = uttNum + 1;
    
    str = fgets(fid);
end

feats = [];
for i=1:size(outList,2)
    feats = [feats; outList(i).feat];    
end




hbin = 50;
gmix = 1;
gres = 0.01;

figure(1);
subplot(5,1,1);
[hprob, hx, gmobj1, gx] = hist2gmm(feats(:,1),hbin,gmix,gres);
bar(hx,hprob);  hold on;
plot(gx,pdf(gmobj1,gx'),'r'); hold off;
title('Speech rate');

subplot(5,1,2);
[hprob, hx, gmobj2, gx] = hist2gmm(feats(:,2),hbin,gmix,gres);
bar(hx,hprob);  hold on;
plot(gx,pdf(gmobj2,gx'),'r'); hold off;
title('Articulation rate');

subplot(5,1,3);
[hprob, hx, gmobj3, gx] = hist2gmm(feats(:,3),hbin,gmix,gres);
bar(hx,hprob);  hold on;
plot(gx,pdf(gmobj3,gx'),'r'); hold off;
title('Phonation time ratio');

subplot(5,1,4);
[hprob, hx, gmobj4, gx] = hist2gmm(feats(:,4),hbin,3,gres);
bar(hx,hprob);  hold on;
plot(gx,pdf(gmobj4,gx'),'r'); hold off;
title('Mean length of runs (m=3)');

subplot(5,1,5);
[hprob, hx, gmobj5, gx] = hist2gmm(feats(:,5),hbin,gmix,gres);
bar(hx,hprob);  hold on;
plot(gx,pdf(gmobj5,gx'),'r'); hold off;
title('Smoothed ufilled pause rate');

figure(2);
subplot(5,1,1);
[hprob, hx, gmobj6, gx] = hist2gmm(feats(:,6),hbin,gmix,gres);
bar(hx,hprob);  hold on;
plot(gx,pdf(gmobj6,gx'),'r'); hold off;
title('Mean length of unfilled pauses');

subplot(5,1,2);
[hprob, hx, gmobj7, gx] = hist2gmm(feats(:,7),hbin,gmix,gres);
bar(hx,hprob);  hold on;
plot(gx,pdf(gmobj7,gx'),'r'); hold off;
title('Smoothed number of long unfilled pause');

subplot(5,1,3);
[hprob, hx, gmobj8, gx] = hist2gmm(feats(:,8),hbin,gmix,gres);
bar(hx,hprob);  hold on;
plot(gx,pdf(gmobj8,gx'),'r'); hold off;
title('Smoothed number of unfilled pause');

subplot(5,1,4);
[hprob, hx, gmobj9, gx] = hist2gmm(feats(:,9),hbin,gmix,gres);
bar(hx,hprob);  hold on;
plot(gx,pdf(gmobj9,gx'),'r'); hold off;
title('Mean deviation of unfilled pause');

subplot(5,1,5);
[hprob, hx, gmobj10, gx] = hist2gmm(feats(:,10),hbin,gmix,gres);
bar(hx,hprob);  hold on;
plot(gx,pdf(gmobj10,gx'),'r'); hold off;
title('Median deviation of unfilled pause');

figure(3);
subplot(5,1,1);
[hprob, hx, gmobj11, gx] = hist2gmm(feats(:,11),hbin,gmix,gres);
bar(hx,hprob);  hold on;
plot(gx,pdf(gmobj11,gx'),'r'); hold off;
title('Standard deviation of unfilled pause');

subplot(5,1,2);
[hprob, hx, gmobj12, gx] = hist2gmm(feats(:,12),hbin,gmix,gres);
bar(hx,hprob);  hold on;
plot(gx,pdf(gmobj12,gx'),'r'); hold off;
title('Duration of silences per word');

subplot(5,1,3);
[hprob, hx, gmobj13, gx] = hist2gmm(feats(:,13),hbin,gmix,gres);
bar(hx,hprob);  hold on;
plot(gx,pdf(gmobj13,gx'),'r'); hold off;
title('Smoothed number of long unfilled pause');

subplot(5,1,4);
[hprob, hx, gmobj14, gx] = hist2gmm(feats(:,14),hbin,gmix,gres);
bar(hx,hprob);  hold on;
plot(gx,pdf(gmobj14,gx'),'r'); hold off;
title('AM score (normalized)');

subplot(5,1,5);
[hprob, hx, gmobj15, gx] = hist2gmm(feats(:,15),hbin,gmix,gres);
bar(hx,hprob);  hold on;
plot(gx,pdf(gmobj15,gx'),'r'); hold off;
title('LM score (normalized)');

save('train_10k_long_ffeat.mat','gmobj1','gmobj2','gmobj3','gmobj4','gmobj5','gmobj14','gmobj15');
