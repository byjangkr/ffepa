clear all; close all;
clc

addpath('func');
infile='../exp_data/librispeech_tri6b_est_set1.filt';
transfile='../exp_data/librispeech_tri6b_est_set1.trans';
amsfile='../exp_data/librispeech_tri6b_est_set1.amscore';
lmsfile='../exp_data/librispeech_tri6b_est_set1.lmscore';
outfile='../exp_data/tmp_librispeech_tri6b_est_set1.feat';

para = adv_ext_flu_feat(infile,transfile,lmsfile,amsfile,outfile);
