#!/bin/bash

## read in all variables from ~/.estimator.ini -- die if not found

if [[ ! -f ~/.estimator.ini ]]; then
	echo "Unable to read shared variables from ~/.estimator.ini.  Exiting."
	exit 1
fi

. ~/.estimator.ini

# we read in BUCKET, WORKDIR from estimator.ini


# if we don't FIND a working directory, we need to create it.  
# if we can't create it, we need to fail with an error message

if [[ ! -d $WORKDIR ]]; then
	mkdir -p $WORKDIR || echo "could not make work directory, dying." && exit 1
fi

cd $WORKDIR

export datestamp=$(date +%Y-%m)

export FILENAME=$(/usr/bin/s3ls $BUCKET | awk -F\| '{print $7}' | grep -v zip | grep -v "test-object" | awk '/csv/{print $NF}' | grep $datestamp | grep -v cost-alloc ) 

# above command sets out proper billing file CSV filename, so we know 
# which file to grab.

echo "getting $BUCKET/$FILENAME and saving into $TARGETFILE"

S3GET=/usr/bin/s3get

if [ ! -x $S3GET ]; then
	echo "could not find $S3GET -- must be installed for this to work"
	exit 1
else
	$S3GET $BUCKET/$FILENAME $TARGETFILE
fi
