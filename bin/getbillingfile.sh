#!/bin/bash
export BUCKET=YOURBUCKETNAMEHERE
export WORKDIR=/home/YOURHOMEDIRHERE

## no changes necessary below this line

export TARGETFILE=$WORKDIR/billing.csv
if [[ $1"x" == "x" ]]; then
	echo "desired filename not set.  saving to billing.csv"
else
	TARGETFILE="$1"
fi

export datestamp=$(date +%Y-%m)

cd $WORKDIR
export FILENAME=$(/usr/bin/s3ls $BUCKET | awk -F\| '{print $7}' | grep -v zip | grep -v "test-object" | awk '/csv/{print $NF}' | grep $datestamp | grep -v cost-alloc ) 

echo "getting $BUCKET/$FILENAME and saving into $TARGETFILE"

/usr/bin/s3get $BUCKET/$FILENAME $TARGETFILE
