
% Plot yearly energy usage
  
c1 = dlmread("out.1.1.txt",",",1,0);
c2 = dlmread("out.1.2.txt",",",1,0);
c3 = dlmread("out.1.3.txt",",",1,0);

for I=1:30
  ec1(I)=sum(c1(I,4:28));
  ec2(I)=sum(c2(I,4:28));
  ec3(I)=sum(c3(I,4:28));
end

figure(2,'visible','off');

year=2020:2049;
%plot(year,ec2,'k-*',year,ec1,'g:',year,ec3,'r:');
plot(year,ec2,'b:',year,ec1,'g:',year,ec3,'r:');

xlabel('Year')
ylabel('Energy Demand (kW/m^2)')
 
title(sprintf("Yearly Energy demand for %d buildings",542));
  
print -dpng plot3.png;
