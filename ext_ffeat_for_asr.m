function output = ext_ffeat_for_asr(infile,transfile,outfile)

% Extract fluency features
% input 
% infile : this is a file that indicate the result of phone recognition
%            using kaldi
%

addpath('ffepa/func');
% need function
% func/sigm.m
% func/mydbinfo.m

%% General variable
phones = {'aa','ae','ah','aw','ay','eh','er','ey','ih','iy',...
              'ow','oy','uh','uw','b','ch','d','dh','dx','f',...
              'g','hh','jh','k','l','m','n','ng','p','r',...
              's','sh','t','th', 'v','w','y','z','sil'};
vowels = {'aa','ae','ah','aw','ay','eh','er','ey','ih','iy',...
              'ow','oy','uh','uw'};
consonants = {'b','ch','d','dh','dx','f','g','hh','jh','k',...
                 'l','m','n','ng','p','r','s','sh','t','th',...
                 'v','w','y','z'};
silence = char('sil');
noword = {'laughter','noise'};

if nargin < 2,
  error('error!!! need argument : infile, outfile');
end

% Read file
para = read_file(infile);

% Read trans file
para = read_trans_file(transfile,para);

% Read score file
%para = read_score_file(lmsfile,para,'lm');
%para = read_score_file(amsfile,para,'am');

% Extract the additive information
para = ext_add_info(para);

% Extract features
para = ext_feat(para);

para = outfile_feat(outfile,para);

output = para;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Read file
    function output = read_file(filename)
    pid = 0;
    para = [];
    preinfo = '';


    [fid, message]= fopen(filename); % file open
    if(fid == -1)
        disp(message);
        disp(filename);
    end

    str = fgets(fid);
    while str ~= -1
        segStr = regexp(str, '\s', 'split');
        finfo = segStr{1};
    
        % save para name : 1st column
        curinfo = finfo;
        if isempty(para),
            pid = pid + 1;
            para(pid).name = finfo;
            para(pid).phnary = [];
            para(pid).durary = [];
            para(pid).begary = [];
            preinfo = finfo;        
        else
            if ~strcmp(preinfo, curinfo),
                pid = pid + 1;
                para(pid).name = finfo;
                para(pid).phnary = [];
                para(pid).durary = [];
                para(pid).begary = [];
                preinfo = finfo;          
            end
        end
    
        % save duration array : 3rd column
        if isempty(para(pid).begary),
            para(pid).begary = str2double(segStr{3});
        else
            para(pid).begary = [para(pid).begary; str2double(segStr{3})];
        end    
    
        % save duration array : 4th column
        if isempty(para(pid).durary),
            para(pid).durary = str2double(segStr{4});
        else
            para(pid).durary = [para(pid).durary; str2double(segStr{4})];
        end
    
        % save phone array : 5th column
        if isempty(para(pid).phnary),
            para(pid).phnary = deblank(segStr{5});
        else
            para(pid).phnary = char(para(pid).phnary, deblank(segStr{5}));
        end
    
        str = fgets(fid);
    end
    st = fclose(fid);
    
    output = para;

    end

%% Read transcription file
    function output = read_trans_file(filename,para)
    
    [fid, message]= fopen(filename); % file open
    if(fid == -1)
        disp(message);
        disp(filename);
    end

    str = fgets(fid);
    while str ~= -1
        trans = [];
        tid = 0;
        segStr = regexp(str, '\s', 'split');
        finfo = segStr{1};
    
        % save para name : 1st column
        if isempty(para),
            error('do not exist speaker information'); 
        end
        
        for i=1:length(para)
            if strcmp(para(i).name,finfo),
                tid = i;
            end
        end
        
        nw = 1;
        for j=2:size(segStr,2)
            word = deblank(segStr{j});
            if (~isempty(word))&&(~strcmp(noword,word)),
                trans{nw} = word;
                nw = nw + 1;
            end
        end
        para(tid).trans = trans;
    
        str = fgets(fid);
    end
    st = fclose(fid);
    
    output = para;

    end

%% Read LM, AM score file
    function output = read_score_file(filename,para,opt)
    
    [fid, message]= fopen(filename); % file open
    if(fid == -1)
        disp(message);
        disp(filename);
    end

    str = fgets(fid);
    while str ~= -1
        sid = 0;
        segStr = regexp(str, '\s', 'split');
        finfo = segStr{1};
        score = str2double(deblank(segStr{2}));
    
        % save para name : 1st column
        if isempty(para),
            error('do not exist speaker information'); 
        end
        
        for i=1:length(para)
            if strcmp(para(i).name,finfo),
                sid = i;
            end
        end        
 
        switch opt 
            case 'lm' 
                para(sid).lmscore = score;
            case 'am'
                para(sid).amscore = score;
        end
    
        str = fgets(fid);
    end
    st = fclose(fid);
    
    output = para;

    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Extract the additive information
    function output = ext_add_info(input)
    inputD = input;
    sizePara = size(inputD,2);
    for i=1:sizePara

        % phone index - 0 : consonants, 1 : vowels, 2 : silence
        tmpcel = deblank(mat2cell(inputD(i).phnary,ones(1,size(inputD(i).phnary,1))));

        phnid=zeros(size(inputD(i).phnary,1),1); % 
        for j=1:size(vowels,2)
            phnid = phnid + strcmpi(tmpcel,vowels{1,j});    
        end
        phnid = phnid + 2*strcmpi(tmpcel,silence);
    
        inputD(i).phnid = phnid;
    
    end
    output = inputD;
    % clear phnid sizePara inputD segStr tmpcel i j
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Extract features
    function output = ext_feat(input)
    inputD = input;
    cutoff = 0.25;

    sizePara = size(inputD,2);
    for k=1:sizePara
        phnid = inputD(k).phnid;
        dur = inputD(k).durary;
        sum_dur = sum(dur);
        sil_dur = dur(phnid==2);
        numwds = length(inputD(k).trans);
        %ams = inputD(k).amscore;
        %lms = inputD(k).lmscore;

        % 1. Speech rate
        SR = nnz(phnid==1)/sum_dur;
        featList = char('SR');
        feat = SR;

        % 2. Articulation rate
        AR = nnz(phnid==1)/sum(dur(phnid~=2));
        featList = char(featList,'AR');
        feat = [feat AR];

        % 3. Phonation time ratio
        PR = sum(dur(phnid==1))/sum_dur;
        featList = char(featList,'PR');
        feat = [feat PR];

        % 4. Mean length of runs
        subdur = dur(2:end-1);
        LR = nnz(phnid==1)/(nnz(subdur(phnid(2:end-1)==2) > cutoff)+1);
        featList = char(featList,'LR');
        feat = [feat LR];

        % 5. Smoothed ufilled pause rate
        SUPR = sum(sigm(sil_dur))/sum_dur;
        featList = char(featList,'SUPR');
        feat = [feat SUPR];

        % 6. Mean length of unfilled pauses
        lenUP = mean(sil_dur);
        featList = char(featList,'lenUP');
        feat = [feat lenUP];
    
        % 7. Smoothed number of long unfilled pause
        SLUP = sum(sigm(sil_dur,[0.5 1.5]));
        featList = char(featList,'SLUP');
        feat = [feat SLUP];
    
        % add features 2017.05.16
        % 8. Smoothed number of unfilled pause
        snumUP = sum(sigm(sil_dur));
        featList = char(featList,'snumUP');
        feat = [feat snumUP];

        % 9. Mean deviation of unfilled pause
        silmeandev = mad(sil_dur,0);
        featList = char(featList,'silmeandev');
        feat = [feat silmeandev];

        % 10. Median deviation of unfilled pause
        silmeddev = mad(sil_dur,1);
        featList = char(featList,'silmeddev');
        feat = [feat silmeddev];
	
        % 11. Standard deviation of unfilled pause
        silstddev = std(sil_dur,1);
        featList = char(featList,'silstddev');
        feat = [feat silstddev];
        
        % 12. Duration of silences per word :
        %   total duration of silences divided by # of words
        silpwd = sum(sil_dur)/numwds;
        featList = char(featList,'silpwd');
        feat = [feat silpwd];
        
        % 13. Smoothed number of long unfilled pause 
        %       divided by number of words
        longpwd = SLUP/numwds;
        featList = char(featList,'longpwd');
        feat = [feat longpwd];
        
        % 14. AM score (normalized)
        %amscore = ams /( sum_dur/0.01);
        %featList = char(featList,'amscore');
        %feat = [feat amscore];
        
        % 15. LM score (normalized)
        %lmscore = lms / numwds;
        %featList = char(featList,'lmscore');
        %feat = [feat lmscore];

        inputD(k).featList = featList;
        inputD(k).feat = feat;
    
    end
    
    output = inputD;

    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% write to feature
    function outpara = outfile_feat(outfile,inpara)

    fid = fopen(outfile,'w');
    for i = 1:size(inpara,2)
        % name information
        inpara(i).outinfo= mydbinfo(inpara(i));
        fprintf(fid,inpara(i).outinfo);
        fprintf(fid,' [');
        fprintf(fid,' %f',inpara(i).feat);
        fprintf(fid,' ]\n');
    end
    fclose(fid);
    outpara = inpara;
    end
    



end
