% clear the workspace
clear;

% get the contents of the folder containing the input data (i.e. all .txt files)
path = '../../Data/MergedData/Experiment1/';
folderInfo = dir(strcat(path, '*.txt')); 
% ignore any invalid entries
folderInfo = folderInfo(~cellfun('isempty', {folderInfo.date}));

% run the neighbourEmbedding script on each file in 'inpath'
for ii = 1:length(folderInfo)
	% iterate through different perplexity values
	for jj = [15, 30, 50]
		% set the random number seed (repeatability)
		rng(1);
		neigbourEmbedding_NoGraphics(path, folderInfo(ii).name, jj);
		fprintf("*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*\n")
		fprintf("Input file %s completed\n", folderInfo(ii).name);
		fprintf("*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*\n\n")
	end
end


function neigbourEmbedding_NoGraphics(path, f_in, perplexity)
	% read the input data to a matlab table
	merged = readtable(strcat(path, f_in));

	% set the index to be 'subreddit'
	merged.Properties.RowNames = table2cell(merged(:,'subreddit'));

	% remove subreddit from the main table
	merged.subreddit = [];

	% convert the 'merged' table to an array
	X = table2array(merged);

	% Use x2p to calculate the distance matrix
	u = perplexity; % perplexity value, default = 15
	P = sparse(x2p(X, u));

	% calculate the algorithm output values
	Y_tsne = tsne_p(P);     % t-distributed SNE
	%_wtsne = wtsne_p(P);   % weighted t-SNE

	% create table for output
	names = merged.Properties.RowNames;
	T = table(names, Y_tsne(:,1),Y_tsne(:,2)); 
	T.Properties.VariableNames = {'subreddit' 'x' 'y'};

	% save output to file
	f_out = strcat(path,'TSNE/',extractBefore(f_in,'.'),'_p',int2str(u),'_tSNE.csv');
	writetable(T, f_out);
end

