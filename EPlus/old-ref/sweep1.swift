type file;

app (file epout, file epoutxml) runEP ( file _runep, file imf, file epw, int orientation, int height)
{
  # runenergyplus CHICAGO-EXAMPLE.imf CHICAGO.epw 
  sh @_runep "--imf" @imf "--epw" @epw "--app" appurl "--out" @epout "--outxml" @epoutxml
            "--params" "orientation" orientation "height" height;
}

app (file _outjson) postproc (file _postproc, file _xml, file _parser)
{
  sh @_postproc "--xml" @_xml "--parser" @_parser "--outjson" @_outjson;
}

file epconfig  <single_file_mapper; file="CHICAGO-EXAMPLE.imf">;
file epweather <single_file_mapper; file="CHICAGO.epw">;
file runep     <single_file_mapper; file="RunEP.sh">;
file postproc  <single_file_mapper; file="postproc.sh">;
file parser  <single_file_mapper; file="parse.js">;

global string appurl = "http://stash.osgconnect.net/+wilde/EnergyPlus-8.0.0.tgz";

int orientIncr = @toInt(@arg("orient","180"));
int maxHeight  = @toInt(@arg("height","1"));
foreach orientation in [0:90:orientIncr] {
  foreach height in [1:maxHeight] {
    file out <single_file_mapper; file=@strcat("ep.", orientation, ".", height, ".out.tgz")>;
    file outxml <single_file_mapper; file=@strcat("ep.", orientation, ".", height, ".xml")>;
    file outjson <single_file_mapper; file=@strcat("ep.", orientation, ".", height, ".json")>;
    (out, outxml) = runEP (runep, epconfig, epweather, orientation, height);
    outjson = postproc (postproc, outxml, parser);

  }
}

/*
app (file epout) ALTrunEP ( file runep, file imf, file epw, int orientation, int height)
{
  # runenergyplus CHICAGO-EXAMPLE.imf CHICAGO.epw 
  sh "-c" @strjoin(@runep,"--imf",@imf,"--epw",@epw,"--app",appurl,"--out",@epout,
                          "--params","orientation",orientation,"height",height," ");
}
*/
