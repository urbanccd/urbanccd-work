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

string  outdir=@arg("outdir","output");
boolean debug=(@arg("debug","")=="debug");

type param {
  string pnum;
  string pname;
  string pvals;
}

param  pset[] = readData(@arg("sweep","sweep.txt"));
string pval[][];

foreach p, pn in pset {
  string val[] = @strsplit(p.pvals,",");
  foreach v, vn in val {
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

  tracef("parameter set:   %s:%s %s:%s %s:%s %s:%s %s:%s %s:%s %s:%s %s:%s\n",
      pset[0].pname, v0, pset[1].pname, v1, pset[2].pname, v2, pset[3].pname, v3,
      pset[4].pname, v4, pset[5].pname, v5, pset[6].pname, v6, pset[7].pname, v7);

  string fileid = @strjoin(["/ep",v0,v1,v2,v3,v4,v5,v6,v7],".");

  if (debug) {
    file outall  <single_file_mapper; file=@strcat(outdir,fileid,".tgz")>;
    file outxml  <single_file_mapper; file=@strcat(outdir,fileid,".xml")>;
    file outjson <single_file_mapper; file=@strcat(outdir,fileid,".json")>;
    (outall, outxml, outjson) = runEP_debug ( epconfig, epweather,
      [pset[0].pname, v0, pset[1].pname, v1, pset[2].pname, v2, pset[3].pname, v3,
       pset[4].pname, v4, pset[5].pname, v5, pset[6].pname, v6, pset[7].pname, v7]);
  }
  else {
    file outjson <single_file_mapper; file=@strcat(outdir,fileid,".json")>;
    outjson = runEP ( epconfig, epweather,
      [pset[0].pname, v0, pset[1].pname, v1, pset[2].pname, v2, pset[3].pname, v3,
       pset[4].pname, v4, pset[5].pname, v5, pset[6].pname, v6, pset[7].pname, v7]);
  }

}}}}}}}}
