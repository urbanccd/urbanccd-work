function [Eelec,Egas] = eecalc_v0_6(Inarray,Distarray,W)
% eecalc  Energy Efficiency Calculator
%
% eecalc implements a stochastic version of the CEN/ISO 13790 based 
% normative energy model in MATLAB.  The function is passed an input cell
% array a distribution cell array and a structure with weather data
%
% The input cell array also contains information about whether or not this
% is an EUI calculation or an energy savings calculation.  If it is an
% energy savings calculation, the model is run twice for each monte carlo
% loop with energy differences calculated and stored
%
%
%%% MATLAB Version of eecalc spreadsheet

% V0.6 03-Jan-2013 RTM added the savings calc from the original MATLAB
% wrapper

% V0.5 20-Dec-2012 RTM
% converted to work with other 0_5 version inputs and outputs and checked
% that it worked with gnu-octave

% V0.4 14-Dec-2012 RTM
% eecalc is now a functional wrapper for parsing inputs and doing the
% stochastic 




% look in the Main values and extract the calc mode and EUI mode right away
temp=cell2mat(Inarray(1)); % extract the EUI Mode: EUI or Retrofit Savings, converting cell to a matrix string
euimode=temp(1);  % save only the first letter of the EUI mode

temp=cell2mat(Inarray(2)); % Extract the calculation mode: Deterministic or Stochastic, converting cell to a matrix string
calcmode=temp(1);  % save only the first letter of the calc mode

NMC=cell2mat(Inarray(3));  %Extract the number of Monte Carlo runs

% look for consistency between number of Monte Carlo runs and calc mode.
% If we have multiple Monte Carlo runs but calc mode is deterministic, only
% do one run.  If we have stochastic and only one Monte Carlo run, then
% convert to deterministic
%printf('Parsing for distributions\n');
if (calcmode=='S')&& NMC>1  
    % if we have selected stochastic calcmode and more than one Monte Carlo
    % run we can look to extract all the distribution variables
  
    [M,~]=size(Distarray);  % find the size of the distribution arrray
   
    Distindex=[];  % start Distindex as an empty array
    Disttype=[];
    for I=1:M
        % extract the entry, convert from a cell to a matrix and aply
        c=cell2mat(Distarray(I,1));  % extract the distribution entry and convert from cell to a matrix
        if ischar(c)  % look to see if the matrix is a char array
            switch lower(c)  % if it is a char array, convert to lower case and use for comparison
                case {'b','u'}  % look to see if the array is a supported distribution letter
                    % store the indicies of all the inputs that have distributions
                    Distindex=[Distindex,I];  % add the index to the list
                    Disttype=[Disttype,c];  % add the distribution type to the list
                otherwise
                    % do nothing if not a supported distribution
            end      
        end
    end
    ndist=length(Distindex);
    
    if euimode=='S'  % if we are asked to calculate savings, parse the input array to extract the retrofit info     
        Retroindex=[];
        Retrotype=[];
        for I=1:M
            c=cell2mat(Distarray(I,6)); % extract the modified distribution entry and convert to a matrix
            if ischar(c)
                switch lower(c)
                    case {'b','u'}
                        Retroindex=[Retroindex,I];
                        Retrotype=[Retrotype,c];
                    otherwise
                        % do nothing if not a supported distribution
                end
            end
        end
        
        ndistretro=length(Retroindex);
        
    else
        ndistretro=0;
    end

else  % if not 'S' and NMC>1 we shouldn't do any stochastic analysis so reset the variables
   calcmode='D';
   NMC=1;
   ndist=0;
    
end

 % save the base input array before modifications for random variables
Randarray=Inarray;
%Etotal=zeros(In.NMC,1);

% create a couple 3-D arrays to hold the energy info
% first index is the monte carlo run number
% second index is month (Jan, Feb, Mar ... Dec)
% third index is category (Heat,Cool,Int Lt,Ext Lt,Fans,Pump,Plug,DHW}
Egas=zeros(NMC,12,8);
Eelec=Egas;
Etotal=Egas;


%printf('Starting Simulations\n')
tic
%h=waitbar(0,'Running Monte Carlo Simulation');
for I=1:NMC
    %%
    % generate the random inputs based on the distributions and copy to the
    % main input cell array to be parsed and sent to the building
    % calculator routine

    for J=1:ndist  % loop through the uncertain input variables
               
        switch Disttype(J)
        case 'u'  %   for a uniform variable
            A = cell2mat(Distarray(Distindex(J),2));  % extract the "A" value from the distrbution
            B = cell2mat(Distarray(Distindex(J),3));  % extract the "B" value from the distribution
            x=rand(1);  % generate vector of uniform random variables between 0 and 1
            randval= A + (B-A)*x;  % scale and shift the uniform random number to A and B variables
        otherwise % 'b' % for a beta variable
            
            A = cell2mat(Distarray(Distindex(J),2));  % extract the "A" value from the distrbution
            B = cell2mat(Distarray(Distindex(J),3));  % extract the "B" value from the distribution
            xmid=cell2mat(Inarray(Distindex(J)));  % get the 
            mid=(xmid-A)./(B-A);  % get normalized mid point of beta distribution
            % compute a and b for the beta distribution
            a=4*mid+1;
            b=5-4*mid;
            
            x=betarand(a,b,1);  % generate a vector of beta random variables
            randval=A+(B-A).*x;  % scale and shift the beta random variable
        end
        
        Randarray(Distindex(J))=mat2cell(randval,1);  % update inarray with the random value
        %randvar(I,J)=randval;  % save the input just in case we want to look at the actual input distribution

    end

    Inrand=parse_inputs_v0_6(Randarray);


    %%
    
    [Ebldg]=bldg_calc_v0_6(Inrand,W);
    
    
    if euimode=='S'  % if we are in savings mode, calc a modified version 
        Ebldg1=Ebldg;
        
        % find the inputs that are modified by the retrofit and generate
        % new random variables
        
        
          
        
        
        Retroarray=Randarray;
            %%
        for J=1:ndistretro  % loop through the uncertain input variables
               
            switch Retrotype(J)
            case 'u'  %   for a uniform variable
                A = cell2mat(Distarray(Retroindex(J),7));  % extract the "A" value for the retrofit distrbution
                B = cell2mat(Distarray(Retroindex(J),8));  % extract the "B" value for the retrofit distribution
                x=rand(1);  % generate vector of uniform random variables between 0 and 1
                randval= A + (B-A)*x;  % scale and shift the uniform random number to A and B variables
            otherwise % 'b' % for a beta variable

                A = cell2mat(Distarray(Retroindex(J),7));  % extract the "A" value for the retrofit distrbution
                B = cell2mat(Distarray(Retroindex(J),8));  % extract the "B" value for the retrofit distribution
                xmid=cell2mat(Distarray(Retroindex(J),5));  % get the peak value for the retrofit distribution
                mid=(xmid-A)./(B-A);  % get normalized mid point of beta distribution
                % compute a and b for the beta distribution
                a=4*mid+1;
                b=5-4*mid;

                x=betarand(a,b,1);  % generate a vector of beta random variables
                randval=A+(B-A).*x;  % scale and shift the beta random variable
            end
            Retroarray(Retroindex(J))=mat2cell(randval,1);  % update inarray with the random value
        end
        Inretro=parse_inputs_v0_6(Retroarray);
        % run the building calc with the modified inputs 
        [Ebldg2]=bldg_calc_v0_6(Inretro,W); 
        
        % calculate the difference in gas and electric usage between the
        % original and modified inputs
        Egas(I,:,:)=Ebldg1.gas-Ebldg2.gas;  
        Eelec(I,:,:)=Ebldg1.elec-Ebldg2.elec;
        
    else  % if not savings mode, output the building gas and electric directly
    
        Egas(I,:,:)=Ebldg.gas;
        Eelec(I,:,:)=Ebldg.elec;
        
    end   
    %waitbar(I/NMC,h);  % update the wait bar
end
%close(h);
toc
return



