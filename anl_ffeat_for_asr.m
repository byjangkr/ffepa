clear all; close all
clc

%filename = 'train_10k_long.ffeat';
filename = 'dev_long.lmscore';
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

hist(feats(:,1),20)