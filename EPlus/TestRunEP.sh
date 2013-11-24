#! /bin/sh

here=$PWD
mkdir -p /dev/shm/$USER
d=$(mktemp -d /dev/shm/$USER/test-eplus-XXXX)
echo Test dir is $d

imf=${1:-CHICAGO-EXAMPLE.imf}

cp $imf CHICAGO.epw $d
cd $d

$here/RunAndReduceEP.sh --imf $imf --epw CHICAGO.epw --outall eptest.tgz --outjson eptest.json --outxml eptest.xml 2>stderr | tee stdout

echo RunAndReduceEP return code is $?
