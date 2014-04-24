#!/bin/bash

## read in all variables from ~/.estimator.ini -- die if not found

if [[ ! -f ~/.estimator.ini ]]; then
	echo "Unable to read shared variables from ~/.estimator.ini.  Exiting."
	exit 1
fi

. ~/.estimator.ini

export datestamp=$(date +%Y-%m)

if [[ ! -d $WORKDIR ]]; then
	mkdir -p $WORKDIR || echo "could not make work directory, dying." && exit 1
fi

cd $WORKDIR

export FILENAME=$(/usr/bin/s3ls $BUCKET | awk -F\| '{print $7}' | grep -v zip | grep -v "test-object" | awk '/csv/{print $NF}' | grep $datestamp | grep -v cost-alloc ) 

echo "getting $BUCKET/$FILENAME and saving into $TARGETFILE"

/usr/bin/s3get $BUCKET/$FILENAME $TARGETFILE
