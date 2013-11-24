type file;

app (file epout, file epoutxml, file outjson) runEPFull ( file runep, file imf, file epw, int orientation, int height)
{
  sh @runep "--imf" @imf "--epw" @epw "--app" appurl "--out" @epout "--outxml" @epoutxml "--outjson" @outjson
            "--params" "orientation" orientation "height" height;
}

app (file outjson) runEP ( file runep, file imf, file epw, int orientation, int height)
{
  sh @runep "--imf" @imf "--epw" @epw "--app" appurl "--out" "out.tgz.skip" "--outxml" "outxml.skip" "--outjson" @outjson
            "--params" "orientation" orientation "height" height;
}

file epconfig  <single_file_mapper; file="CHICAGO-EXAMPLE.imf">;
file epweather <single_file_mapper; file="CHICAGO.epw">;
file runep     <single_file_mapper; file="RunAndReduceEP.sh">;

global string appurl = "http://stash.osgconnect.net/+wilde/EnergyPlus-8.0.0.tgz";

int orientIncr = @toInt(@arg("orient","180"));
int maxHeight  = @toInt(@arg("height","1"));
foreach orientation in [0:90:orientIncr] {
  foreach height in [1:maxHeight] {
    #file out <single_file_mapper; file=@strcat("output/ep.", orientation, ".", height, ".out.tgz")>;
    #file outxml <single_file_mapper; file=@strcat("output/ep.", orientation, ".", height, ".xml")>;
    file outjson <single_file_mapper; file=@strcat("output/ep.", orientation, ".", height, ".json")>;
#    (out, outxml, outjson) = runEP (runep, epconfig, epweather, orientation, height);
    outjson = runEP (runep, epconfig, epweather, orientation, height);
  }
}
