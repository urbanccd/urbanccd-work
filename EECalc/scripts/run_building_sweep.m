
%%%Script to run MATLAB Version of eecalc spreadsheet
%%%Modified by Brendan Albano to output results to a .csv instead of plotting

if exist('OCTAVE_VERSION')  % if this is octave and not matlab, load packages
  pkg load statistics io
end

arg_list = argv ();
buildingfile = arg_list{1}
weatherfile  = arg_list{2}
sweepfile    = arg_list{3}
outputfile   = arg_list{4}
climateIncr  = str2num(arg_list{5})
nYears       = str2num(arg_list{6})

paramnamesfile = file_in_loadpath('paramnames.txt');

dummyin = fopen("/etc/group","r");
dummyin

outfid = fopen(outputfile, "w");

outfid

pfid=fopen(paramnamesfile,'r');

if pfid==-1
  error(sprintf('File %s not found',paramnamesfile))
end

np=1;
while ~feof(pfid)
  param{np++} =fgetl(pfid);
end

fclose(pfid);

Params = struct; 

for n = 1:numel(param) 
  Params = setfield(Params, param{n}, n); 
  printf("%d %s\n", n, param{n});
endfor 

if ~exist(buildingfile,'file')
  error(sprintf('File %s not found',buildingfile));
end

if ~exist(weatherfile,'file')
  error(sprintf('File %s not found',weatherfile));
end

if ~exist(sweepfile,'file')
  error(sprintf('File %s not found',sweepfile));
end

[ParamNames,Inarray,Distarray]=read_inputs_v0_6(buildingfile);
printf('Done reading building file\n')

SaveInarray = Inarray;
SaveDistarray = Distarray;
	
[SweepNames,SweepInarray,SweepDistarray]=read_inputs_v0_6(sweepfile);
printf('Done reading sweep file\n')

load(weatherfile, 'W'); % W=read_epw_v0_6(weatherfile); save(weatherfile,'W')
printf('loaded weather\n');
startW = W;

[N,M] = size(ParamNames);
printf("Paramnames: N=%d M=%d\n", N, M);
[N,M] = size(Inarray);
printf("Inarray:    N=%d M=%d\n", N, M);
[N,M] = size(Distarray);
printf("Distarray:: N=%d M=%d\n", N, M);

[N,M] = size(SweepNames);
printf("SweepNames:     N=%d M=%d\n", N, M);
[N,M] = size(SweepInarray);
printf("SweepInarray:   N=%d M=%d\n", N, M);
[N,M] = size(SweepDistarray);
printf("SweepDistarray: N=%d M=%d\n", N, M);


startYear=2020;
SimNo=1;

phdr=[];
pval=[];
for p = 1:N
 
  if (SweepNames{p} != '-') 

    pnum = getfield(Params,SweepNames{p});
%    printf("pnum %d is [%s,%d]\n", p, SweepNames{p}, pnum);
    phdr = [phdr, ', ', SweepNames{p} ];
    pval = [pval, SweepInarray{p} ];
    Inarray{pnum} = SweepInarray{p};
    Distarray{pnum} = SweepDistarray{p};
 
  else % End of a parameter set: run the model for N years
    for year=[0:nYears-1]
%      climateFactor=power(1.05,year);
      
%      fprintf(outfid," Simulation number %d\n", SimNo);
      [Eelec,Egas] = eecalc_v0_6(Inarray,Distarray,W);

      Etotal=Eelec+Egas;
  
  	%%
  
  	Emonth=sum(Etotal,3);  % sum over categories to get monte carlo monthly total
        EmonthGas=sum(Egas,3);
        EmonthElec=sum(Eelec,3);
  	Etot=sum(Emonth,2);  % sum over the months to get a monte carlo yearly total
  	Nruns=length(Etot);
  
  	if Nruns>1  % if we have more than one run, compute and plot PDFs and CDFs
  
  		% compute the empirical and kernel density PDF and CDF
  		Nhistbins=64;
  		[epdf,ecdf,ebins]=epdfcdf(Etot,Nhistbins);  % 
  
  		Nkdebins=256;
  		[~,kpdf,kbins,kcdf]=kde(Etot,Nkdebins);
  
  		%% plot out the annual results
  		figure(1, 'visible', 'off');
  		subplot(2,1,1)
  		h=bar(ebins,epdf,1);
  		set(h,'facecolor',[0.7,0.7,1],'edgecolor',[0.5,0.5,1])
  		hold on
  		plot(kbins,kpdf,'r')
  print -dpng plot1.png
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
  
  print -dpng plot2.png;
  
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
  figure(2,'visible','off');
  		m=1:12;
  		plot(m,kmed,'k-*',m,klb,'r:',m,kub,'r:');
  		A=axis; A(1:2)=[0.75,12.25];axis(A);
  
  		set(gca,'xtick',m);
  		set(gca,'XTickLabel',{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',''})
  		xlabel('Month')
  		ylabel('EUI (kW/m^2)')
  
  		tstring=sprintf('Monthly Median EUI with 5%% and 95%% bounds for N=%d runs',Nruns);
  		title(tstring)
  
       print -dpng plot3.png;
  
  	else  % if we only have 1 run
          if (SimNo == 1) fprintf(outfid,"Sim#, Year, ClimateFactor%s, Elec01, Elec02, Elec03, Elec04, Elec05, Elec06, Elec07, Elec08, Elec09, Elec10, Elec11, Elec12, Gas01, Gas02, Gas03, Gas04, Gas05, Gas06, Gas07, Gas08, Gas09, Gas10, Gas11, Gas12\n", phdr); endif % NOTE: phdr starts with " ,"
          fprintf(outfid,"%d, %d, %.6f, ", SimNo, startYear+year, climateIncr);
          fprintf(outfid,"%.2f, ", pval, EmonthElec, EmonthGas);
          fprintf(outfid,"\n");
          
%	  fdisp(outfid,"data:");
%         fdisp(outfid,phdr)
%         fdisp(outfid,pval);
%         fdisp(outfid,EmonthElec)
%         fdisp(outfid,EmonthGas)
%         fdisp(outfid,Emonth);
          
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
      % Reset world to base building model state:
      Inarray = SaveInarray;
      DistArray = SaveDistarray;
      SimNo++;
      W.mdbt += climateIncr;
      W.mhdbt += climateIncr;
      W.msolar += climateIncr;
      W.mEgh += climateIncr;
      W.mhEgh += climateIncr;
    endfor % year
    phdr = [];
    pval = [];
    W = startW;
  endif
endfor % param set p
fclose (outfid);
