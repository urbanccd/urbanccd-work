%%%Script to run MATLAB Version of eecalc spreadsheet

% comment these lines out to use the gui to select the files
%inputsfile='matlab_eecalc_v0_6.txt';
%weatherfile='chicago_tmy.epw';

if exist('OCTAVE_VERSION')  % if this is octave and not matlab, load packages
    pkg load statistics io
end

if ~exist('inputsfile','var')
    %select the file with a gui
    [filename,pathname]=uigetfile('.txt','Select CSV Text Fileto Open');
    switch filename
        case {0} 
            % User cancelled out, so quit with an error dialog
            error('User cancelled script run')
        otherwise
            inputsfile=[pathname,filename]; 
    end % switch filename
end

if ~exist(inputsfile,'file')
    error(sprintf('File %s not found',inputsfile));
end
if ~exist('weatherfile','var')
    %select the file with a gui
    [filename,pathname]=uigetfile('.epw','Select EPW to Open');
    switch filename
        case {0} 
            % User cancelled out, so quit with an error dialog
            error('User cancelled file input')
        otherwise
            weatherfile=[pathname,filename]; 
    end % switch filename
end


if ~exist(weatherfile,'file')
    error(sprintf('File %s not found',weatherfile));
end

if ~exist('Inarray','var')
    printf('Reading input file')
    [Inarray,Distarray]=read_inputs_v0_6(inputsfile);
end

if ~exist('W','var')
        printf('Reading weather file')
    W=read_epw_v0_6(weatherfile);
end
printf('Done reading input files')

[Eelec,Egas] = eecalc_v0_6(Inarray,Distarray,W);
Etotal=Eelec+Egas;

%%

Emonth=sum(Etotal,3);  % sum over categories to get monte carlo monthly total
Etot=sum(Emonth,2);  % sum over the months to get a monte carlo yearly total
Nruns=length(Etot);

if Nruns>1  % if we have more than one run, compute and plot PDFs and CDFs

    % compute the empirical and kernel density PDF and CDF
    Nhistbins=64;
    [epdf,ecdf,ebins]=epdfcdf(Etot,Nhistbins);  % 

    Nkdebins=256;
    [~,kpdf,kbins,kcdf]=kde(Etot,Nkdebins);

    %% plot out the annual results
    figure(1)



    subplot(2,1,1)


    h=bar(ebins,epdf,1);
    set(h,'facecolor',[0.7,0.7,1],'edgecolor',[0.5,0.5,1])
    hold on
    plot(kbins,kpdf,'r')
    hold off
    xrange=[min(kbins),max(kbins)];
    yrange=[min(epdf),max(epdf)];
    axis([xrange(1),xrange(2),0,yrange(2)*1.2]);

    tstring=sprintf('PDF and CDF for EUI with N=%d runs',Nruns);
    title(tstring)


    ylabel('PDF');

    subplot(2,1,2)

    h=bar(ebins,ecdf,1);
    set(h,'facecolor',[0.7,0.7,1],'edgecolor',[0.5,0.5,1])
    hold on
    plot(kbins,kcdf,'r')
    hold off

    axis([xrange(1),xrange(2),0,1])
    xlabel('EUI kW/m^2')
    ylabel('CDF')

    %% compute the monthly EUI mean and confidence bounds

    Nkdebins=256;
    Lbound=0.05;  % lower bound is 5% p(X<x)
    Ubound=0.95; % upper bound is 95% p(X<x)
    klb=zeros(12,1);
    kub=klb;
    kmed=klb;

    for I=1:12

        [~,~,kbins,kcdf]=kde(Emonth(:,I),Nkdebins);
        [~,Imin]=min(abs(kcdf-Lbound));  % find the index of the cdf value closest to the lower bound
        klb(I)=kbins(Imin); % extract the EUI associated with the lower bound index
        [~,Imax]=min(abs(kcdf-Ubound)); % find the index of the cdf value closest to the upper bound
        kub(I)=kbins(Imax); % extract the EUI associated with the upper bound index
        [~,Imed]=min(abs(kcdf-0.5)); % find the index of the cdf value closest to 0.1
        kmed(I)=kbins(Imed);  % extract the EUI associated with the median

    end
    %%  Plot out the monthly EUI
    figure(2)
    m=1:12;
    plot(m,kmed,'k-*',m,klb,'r:',m,kub,'r:');
    A=axis; A(1:2)=[0.75,12.25];axis(A);

    set(gca,'xtick',m);
    set(gca,'XTickLabel',{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',''})
    xlabel('Month')
    ylabel('EUI (kW/m^2)')

    tstring=sprintf('Monthly Median EUI with 5%% and 95%% bounds for N=%d runs',Nruns);
    title(tstring)

else  % if we only have 1 run
    % printflay the total computations
    Emonth'
    Etot

    figure(1)
    m=1:12;
    plot(m,Emonth,'k-*');
    A=axis; A(1:2)=[0.75,12.25];axis(A);

    set(gca,'xtick',m);
    set(gca,'XTickLabel',{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',''})
    xlabel('Month')
    ylabel('EUI (kWh/m^2)')

    tstring=sprintf('Monthly Median EUI with Annual EUI=%0.1f kWh/m^2',Etot);
    title(tstring)
    

end


