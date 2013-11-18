type file;

app (file sweepout, file sout, file serr) OLDbuildingSweep (file script, file building, file weather, file sweep)
{
  # run_building_sweep.m t01.txt chicago_tmy.mat sweep.txt out.txt
  sh @script @building @weather @sweep @sweepout stdout=@sout stderr=@serr;
}

app (file sweepout, file sout, file serr) buildingSweep (file building, file weather, file sweep, float deltaT, int years)
{
  # scripts/building_sweep.sh t01.txt chicago_tmy01.mat nosweep.txt out.1.3.txt .3 30
  building_sweep @building @weather @sweep @sweepout deltaT years stdout=@sout stderr=@serr;
}

file buildings[] <filesys_mapper; location="./building", suffix=".txt">;
file climates[]  <filesys_mapper; location="./weather", suffix=".mat">;
file sweepDef    <single_file_mapper; file="nosweep.txt">;

float deltaT = 0.3;
int   years  = 30;

foreach building, b in buildings {
  foreach climate, c in climates {
    file sweepout <single_file_mapper; file=@strcat("output/eecalc.",b,".",c,".out")>;
    file sout     <single_file_mapper; file=@strcat("output/eecalc.",b,".",c,".stdout")>;
    file serr     <single_file_mapper; file=@strcat("output/eecalc.",b,".",c,".stderr")>;
    (sweepout, sout, serr) = buildingSweep (building, climate, sweepDef, deltaT, years);
  }
}
