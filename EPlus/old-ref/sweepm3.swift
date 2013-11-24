type file;

app (file epout, file epoutxml) runEP ( file _runep, file imf, file epw, int orientation, int height, int width,int length, float wwr, string system)
{
  # runenergyplus SWEEP_RECT.imf CHICAGO.epw 
  sh @_runep "--imf" @imf "--epw" @epw "--app" appurl "--out" @epout "--outxml" @epoutxml
            "--params" "ORIENT" orientation "NumberFloors" height "W" width "L" length "WINTOP" wwr "HVACSystem" system "ENDMONTH" 12 "ENDDAY" 31;
}

app (file _outjson) postproc (file _postproc, file _xml, file _parser)
{
  sh @_postproc "--xml" @_xml "--parser" @_parser "--outjson" @_outjson;
}

file epconfig  <single_file_mapper; file="SWEEP_RECT.imf">;
file epweather <single_file_mapper; file="CHICAGO.epw">;
file runep     <single_file_mapper; file="RunEP.sh">;
file postproc  <single_file_mapper; file="postproc.sh">;
file parser  <single_file_mapper; file="parse.js">;

global string appurl = "http://stash.osgconnect.net/+wilde/EnergyPlus-8.0.0.tgz";

string outd=@arg("outd","output");

#foreach orientation in [0] {
#  foreach height in [5] {
#   foreach width in [10,20] {
#    foreach length in [10,20] {
#     foreach wwr in [1.8] {
#      foreach system in ["SYSTEM7"] {


foreach orientation in [0,30,60] {
  foreach height in [5,10,15,20] {
   foreach width in [10,20,30,40] {
   foreach length in [10,20,30,40] {
     foreach wwr in [1.8,2.5,3.5] {
      foreach system in ["SYSTEM7", "OptimizedVAV", "DOASFCU", "DOASECMFCU"] {

    tracef("orientation:%i height:%i width:%i length:%i wwr:%f system:%s\n", orientation, height, width,length,wwr,system);
    file out <single_file_mapper; file=@strcat(outd,"/ep.", orientation, ".", height, ".",width,".",length,".",wwr,".",system,".out.tgz")>;
    file outxml <single_file_mapper; file=@strcat(outd,"/ep.", orientation, ".", height, ".",width,".",length,".",wwr,".",system,".xml")>;
   file outjson <single_file_mapper; file=@strcat(outd,"/ep.", orientation, ".", height, ".",width,".",length,".",wwr,".",system, ".json")>;
    (out, outxml) = runEP (runep, epconfig, epweather, orientation, height,width,length,wwr,system);
    outjson = postproc (postproc, outxml, parser);

   }
  }
}
}
}
}
