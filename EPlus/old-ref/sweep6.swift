type file;

app (file all, file xml, file json) runEP_debug ( file imf, file epw, string params[] )
{
  RunEP "--imf" @imf "--epw" @epw "--outall" @all "--outxml" @xml "--outjson" @json "--params" params;
}

app (file json) runEP ( file imf, file epw, string params[] )
{
  RunEP "--imf" @imf "--epw" @epw "--outall" "temp.tgz" "--outxml" "temp.xml" "--outjson" @json "--params" params;
}


file epconfig  <single_file_mapper; file=@arg("epconfig",  "SWEEP_RECT.imf")>;
file epweather <single_file_mapper; file=@arg("epweather", "CHICAGO.epw")>;

string outd=@arg("outdir","output");
boolean debug=(@arg("debug","")=="debug");

type param {
  string pnum;
  string pname;
  string pvals;
}

string pval[][];

param pset[] = readData("params");

foreach p, pn in pset {
  tracef("param=%s val=%s\n", p.pname, p.pvals);
  string val[] = @strsplit(p.pvals,",");
  foreach v, vn in val {
    tracef(" run: param=%s value=%s\n", p.pname, v);
    pval[pn][vn]=v;
  }
}

foreach v0 in pval[0] {
foreach v1 in pval[1] {
foreach v2 in pval[2] {
foreach v3 in pval[3] {
foreach v4 in pval[4] {
foreach v5 in pval[5] {
foreach v6 in pval[6] {
foreach v7 in pval[7] {

  tracef("orientation:%s height:%s width:%s length:%s wwr:%s system:%s endmonth:%s endday:%s\n", v0,v1,v2,v3,v4,v5,v6,v7);

  string fileid = @strjoin(["/ep",v0,v1,v2,v3,v4,v5,v6,v7],".");

  if (debug) {
    file outall  <single_file_mapper; file=@strcat(outd,fileid,".tgz")>;
    file outxml  <single_file_mapper; file=@strcat(outd,fileid,".xml")>;
    file outjson <single_file_mapper; file=@strcat(outd,fileid,".json")>;
    (outall, outxml, outjson) = runEP_debug ( epconfig, epweather,
      [pset[0].pname, v0, pset[1].pname, v1, pset[2].pname, v2, pset[3].pname, v3,
       pset[4].pname, v4, pset[5].pname, v5, pset[6].pname, v6, pset[7].pname, v7]);
  }
  else {
    file outjson <single_file_mapper; file=@strcat(outd,fileid,".json")>;
    outjson = runEP ( epconfig, epweather,
      [pset[0].pname, v0, pset[1].pname, v1, pset[2].pname, v2, pset[3].pname, v3,
       pset[4].pname, v4, pset[5].pname, v5, pset[6].pname, v6, pset[7].pname, v7]);
  }

}}}}}}}}






# NOTES:

/* 

"ORIENT" orientation
NumberFloors" height 
"W" width
"L" length
"WINTOP" wwr 
"HVACSystem" system 
"ENDMONTH" 1
"ENDDAY" 2;
*/

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