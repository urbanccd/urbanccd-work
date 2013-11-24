type file;

app (file all, file xml, file json) runEP ( file imf, file epw, string params[] )
{
  RunEP "--imf" @imf "--epw" @epw "--outall" @all "--outxml" @xml "--outjson" @json "--params" params;
}

file epconfig  <single_file_mapper; file=@arg("epconfig",  "SWEEP_RECT.imf")>;
file epweather <single_file_mapper; file=@arg("epweather", "CHICAGO.epw")>;

string outd=@arg("outdir","output");

string a_orientation[] = @strsplit(@arg( "orientation", "0,20,40"),",");
string a_height[]      = @strsplit(@arg( "height",      "5"),",");
string a_width[]       = @strsplit(@arg( "width",       "10,20"),",");
string a_length[]      = @strsplit(@arg( "length",      "10,20"),",");
string a_wwr[]         = @strsplit(@arg( "wwr",         "1.8"),",");
string a_system[]      = @strsplit(@arg( "system",      "SYSTEM7"),",");

foreach orientation in a_orientation {
 foreach height     in a_height       {
  foreach width     in a_width        {
   foreach length   in a_length       {
    foreach wwr     in a_wwr          {
     foreach system in a_system       {

      tracef("orientation:%s height:%s width:%s length:%s wwr:%s system:%s\n", orientation,height,width,length,wwr,system);

      string fileid = @strjoin(["/ep",orientation,height,width,length,wwr,system],".");
      file outall  <single_file_mapper; file=@strcat(outd,fileid,".tgz")>;
      file outxml  <single_file_mapper; file=@strcat(outd,fileid,".xml")>;
      file outjson <single_file_mapper; file=@strcat(outd,fileid,".json")>;
      (outall, outxml, outjson) = runEP ( epconfig, epweather,
             ["ORIENT",orientation,"NumberFloors",height,"W",width,"L",length,"wwr",wwr,"HVACSystem",system]);
     }
    }
   }
  }
 }
}





# NOTES:

"ORIENT" orientation
NumberFloors" height 
"W" width
"L" length
"WINTOP" wwr 
"HVACSystem" system 
"ENDMONTH" 1
"ENDDAY" 2;


/*
##set1 ORIENT[] 0
##set1 NumberFloors[] 6
##set1 W[] 34
##set1 L[] 91
##set1 FF[] 4
##set1 PERIOFF[] 4.6
##set1 COREOFF[] 13.7
##set1 WINOFF[] 1
##set1 WINTOP[] 3
HVACSystem
*/

#foreach orientation in [0,30,60] {
#  foreach height in [5,10,15,20] {
#   foreach width in [10,20,30,40] {
#   foreach length in [10,20,30,40] {
#     foreach wwr in [1.8,2.5,3.5] {
#      foreach system in ["SYSTEM7", "OptimizedVAV", "DOASFCU", "DOASECMFCU"] {

# OLD:

/* 

app (file outjson) OLD_1_runEP ( file runep, file imf, file epw, int orientation, int height)
{
  sh @runep "--imf" @imf "--epw" @epw "--app" appurl "--out" "out.tgz.skip" "--outxml" "outxml.skip" "--outjson" @outjson
            "--params" "orientation" orientation "height" height;
}

app (file epout, file epoutxml) OLDrunEP ( file _runep, file imf, file epw, int orientation, int height, int width,int length, float wwr, string system)
{
  # runenergyplus SWEEP_RECT.imf CHICAGO.epw 
  sh @_runep "--imf" @imf "--epw" @epw "--app" appurl "--out" @epout "--outxml" @epoutxml
            "--params" "ORIENT" orientation "NumberFloors" height "W" width "L" length "WINTOP" wwr "HVACSystem" system "ENDMONTH" 1 "ENDDAY" 2;
}

*/