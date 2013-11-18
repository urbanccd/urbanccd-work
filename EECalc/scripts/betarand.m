function [ y ] = betarand(A,B, n)
%betarnd generates a random number 
%   Detailed explanation goes here

%  check for betarnd or not (doesn't exist in base matlab, but does in
%  stats toolbox and ocave

if exist('OCTAVE_VERSION')  % check to see if this is gnu-octave or not
    y=betarnd(A,B,n);  % if gnu-octave use built in beta random
else
    % if not gnu-octave, generate from a uniform random number and the
    %  inverse incomplete beta function
    y=betaincinv(rand(n),A,B); 
end

end

