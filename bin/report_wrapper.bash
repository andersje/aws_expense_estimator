#!/bin/bash

INIFILE="~/.estimator.ini"


## check for inifile, die if we don't find it.  
## Sure, in initial testing we'll always
## find it -- if anyone has followed directions.  
## But, maybe somebody deleted it later on.

if [[ ! -f ~/.estimator.ini ]]; then
	echo "unable to find required ~/.estimator.ini file -- dying"
	exit 1
else
	. ~/.estimator.ini	
fi

# fetch the billing file, ensure it exists.
# if it does, run our report generator.

$BINPATH/getbillingfile.bash > /dev/null 2>/dev/null 
if [[ -f $TARGETFILE ]]; then
	$BINPATH/csv_report_generator.pl $TARGETFILE > $CSV_TARGET 

	# as long as we have a report, we need to mail it out.	
	if [[ -f $CSV_TARGET ]]; then 
		$BINPATH/mailit_attachment.bash
	else
		#whoa, we SHOULD have generated a report, but failed.
		# log an error and die.
		echo "$CSV_TARGET not generated by $BINPATH/csv_report_generator.pl.  Exiting"
		exit 1
	fi
else
	## we tried to retrieve the file but did not success.  that's bad.
	echo "$TARGETFILE never retrieved by $BINPATH/getbillingfile.bash.  Exiting"
	exit 1
fi

## if we got to this point, everything must've worked.  die happy.
exit 0
