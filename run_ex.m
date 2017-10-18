clear; close all;
clc

infile='sample_data/sample.filt';
transfile='sample_data/sample.trans';
amsfile='sample_data/sample.amscore';
lmsfile='sample_data/sample.lmscore';
outfile='sample_data/output_sample.feat';

% ver 1
%para = adv_ext_flu_feat3(infile,transfile,outfile);

% ver 2
% para = adv_ext_flu_feat3(infile,transfile,lmsfile,amsfile,outfile);
