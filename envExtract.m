function [sample]= envExtract(sample, avgtime, Fs)
%% function [sample]= envExtract(sample, avgtime, Fs)
%   this function takes a vector of sound signal samples and returns the
%   signal filtered
%inputs: vector samples, time over which the filter will average the points
%           and the sampling rate at which the sample were taken            

sample=sample.^2;
N = (avgtime*Fs-1)/2 ; %make sure the average will be taken symmetrically 
N=round(N);    
K = 2*N + 1 ;
n=length(sample) ;
% symmetric K-point average moving filter
for ipt = N+1:n-N
    newpoint=0;
    for i=ipt-N:ipt+N
        newpoint=newpoint+sample(i) ;
    end
    newpoint = newpoint/K;
    sample(ipt) = newpoint ;
end
end

