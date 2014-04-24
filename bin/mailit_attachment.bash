#!/bin/bash

## read in the user-edited variables from ~/.estimator.ini.  Die if not found

if [[ ! -f ~/.estimator.ini ]]; then
	echo "Unable to read shared variables from ~/.estimator.ini.  Exiting."
	exit 1
fi

. ~/.estimator.ini


SOURCEFILE=$WORKDIR/curr_estimated.csv
ESTIMATED_COST=$(tail -1 $SOURCEFILE | awk -F, '{print $NF}' | sed -e 's/\"//g')
SUBJECT="projected amazon costs for current month ($ESTIMATED_COST)"
BODY="At current, total estimated costs for this month are $ESTIMATED_COST.  For more details, open the attached csv file with excel."

if [ -f  $SOURCEFILE ]; then
	for TARGET in $TARGETS; do
		echo $BODY | sendEmail -f $FROMADDR -t $TARGET -u $SUBJECT -a $SOURCEFILE -s $MAIL_SERVER
	done
else
	echo "failure to read report file for $COMPANYNAME" | mail $ADMINEMAIL -s 'aws cost report issues'
fi
