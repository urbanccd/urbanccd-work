
%%%Script to run MATLAB Version of eecalc spreadsheet
%%%Modified by Brendan Albano to output results to a .csv instead of plotting

% comment these lines out to use the gui to select the files

     arg_list = argv ();
     inputsfile = arg_list{1}
     outputfile = arg_list{2}

 printf("inputsfile=%s outputfile=%s\n", inputsfile, outputfile);

%inputsfiles = textread("batch_input/files_list.txt", "%s")

printf('STARTING\n');

fid = fopen(outputfile, "w");
fprintf(fid,"inputsfile=%s outputfile=%s\n", inputsfile, outputfile);
fprintf(fid,"inputsfile=%s outputfile=%s\n", inputsfile, outputfile);
fprintf(fid,"inputsfile=%s outputfile=%s\n", inputsfile, outputfile);

%for i = 1:length(inputsfiles)

%	inputsfile=inputsfiles{i};
	printf('%s\n',inputsfile)
	weatherfile='chicago_tmy.epw';

	if exist('OCTAVE_VERSION')  % if this is octave and not matlab, load packages
		pkg load statistics io
	end

if(true)
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

	%For the batch run, always reread the input file
	printf('Reading input file\n')
	[Inarray,Distarray]=read_inputs_v0_6(inputsfile);
	printf('Done reading inputsfile\n')
	

	if ~exist('W','var')
		printf('Reading weather file\n')
		W=read_epw_v0_6(weatherfile);
	end
	printf('Done reading input files\n')

	printf('saving state\n');
	save('eecalc_data.mat', 'Inarray', 'Distarray', 'W');
end 

printf('loading state\n');
	load('eecalc_data.mat', 'Inarray', 'Distarray', 'W');
printf('loaded state\n');

fprintf(fid,"1: inputsfile=%s outputfile=%s\n", inputsfile, outputfile);

%[Inarray,Distarray]=read_inputs_v0_6('batch_input/1.0.txt');
%printf("NWall=%10.10f\n", Inarray{69,1});
%Inarray{69,1} *= 1.2;
%printf("NWall=%10.10f\n", Inarray{69,1});

NWall = Inarray{69,1};
EWall = Inarray{71,1};
SWall = Inarray{73,1};
WWall = Inarray{75,1};

for NWinRatio = .2 : .2 : .8

  NWin = NWall * NWinRatio;
  Inarray{78,1} = NWin;

  for EWinRatio = .2 : .2 : .8

    EWin = WWall * EWinRatio;
    Inarray{80,1} = EWin;

    for SWinRatio = .2 : .2 : .8

      SWin = SWall * SWinRatio;
      Inarray{82,1} = SWin;

      for WWinRatio = .2 : .2 : .8

        WWin = WWall * WWinRatio;
        Inarray{84,1} = WWin;

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
		% printf the total computations
		%Emonth'
		%Etot
		
                fprintf(fid,"Window area N, E, S, W: %10.10f, %10.10f, %10.10f, %10.10f\n", NWin, EWin, SWin, WWin);
		csvwrite (fid, Emonth);
%		fclose (fid);
	
		%figure(1)
		%m=1:12;
		%plot(m,Emonth,'k-*');
		%A=axis; A(1:2)=[0.75,12.25];axis(A);

		%set(gca,'xtick',m);
		%set(gca,'XTickLabel',{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',''})
		%xlabel('Month')
		%ylabel('EUI (kWh/m^2)')

		%tstring=sprintf('Monthly Median EUI with Annual EUI=%0.1f kWh/m^2',Etot);
		%title(tstring)
	

	end
endfor
endfor
endfor
endfor
fclose (fid);
%endfor
