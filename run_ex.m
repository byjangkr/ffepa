clear all; close all;
clc

infile='sample_data/sample_ctm_39phn.filt';
outfile='sample_data/sample.feat';

para = ext_flu_feat(infile,outfile);
