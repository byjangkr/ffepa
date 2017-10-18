#!/bin/bash

infile=sample_data/sample.filt
transfile=sample_data/sample.trans
amsfile=sample_data/sample.amscore
lmsfile=sample_data/sample.lmscore
outfile=sample_data/output_sample.feat

matlab -nodisplay -r "addpath func; adv_ext_flu_feat3 $infile $transfile $lmsfile $lmsfile $outfile ; quit"
