#!/bin/bash

infile=`pwd`/sample_data/sample_ctm_39phn.filt
outfile=`pwd`/sample_data/sample.feat

matlab -nodisplay -r "ext_flu_feat $infile $outfile ; quit"
