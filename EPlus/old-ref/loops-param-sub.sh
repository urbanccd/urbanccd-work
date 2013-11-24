# From protlib loops code:

# Update the .cfg files created above, using values from the $params file
#   FIXME: make this a shared function, imported from a swift or oops library

while read pv; do
  p=$(echo $pv | sed -e 's/[ ]*=.*//')
  v=$(echo $pv | sed -e 's/^.*=[ ]*//')
  for f in *.cfg; do
        #dont replace energy function since multiple possible
        #if [ "$p" != "ENERGY FUNCTION" ]; then sed -i $f -e "/^$p/s/=.*/=$v/g"; fi
        
        #this replaces above sed s delimiter with | so that the par file path / are acceptable
        if [ "$p" != "ENERGY FUNCTION" ]; then sed -i $f -e "/^$p/s|=.*|=$v|g"; fi
  done
done <$params
