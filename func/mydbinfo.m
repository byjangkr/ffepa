function outpara = mydbinfo(inpara)
% This function is that extract more information of file name.
% If you want to extracting more information from file name
% or writing more information to output file, you must
% modify to this function.
% Ex) TIMIT file name -> FADG0_SI1279
%     F - sex
%     ADG0 - speaker index
%     SI - sentence type
%     1279 - sentence number

	%% default code
	 %inpara.outinfo = sprintf('%s',inpara.name);

	% for est db
	segStr = regexp(inpara.name, '_', 'split');
    inpara.gender = deblank(segStr{1});
    inpara.set = str2double(segStr{2});
    inpara.spkname = deblank(segStr{3});
    inpara.task = str2double(segStr{4});
    inpara.outinfo = sprintf('%s %d %d',inpara.spkname,inpara.set,inpara.task);

	outpara = inpara.outinfo;


end
