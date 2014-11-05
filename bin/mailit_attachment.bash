#!/bin/bash

## read in the user-edited variables from ~/.estimator.ini.  Die if not found

if [[ ! -f ~/.estimator.ini ]]; then
  echo "Unable to read shared variables from ~/.estimator.ini.  Exiting."
  exit 1
fi

. ~/.estimator.ini

if [[ $REPORTFILE"x" == "x" ]]; then
  export REPORTFILE=$WORKDIR/last_report_mailing.log
fi

CSV_TARGET=$CSV_TARGET
ESTIMATED_COST=$(tail -1 $CSV_TARGET | awk -F, '{print $NF}' | sed -e 's/\"//g')
SUBJECT="Projected amazon costs for current month ($ESTIMATED_COST)"
BODY="At current, total estimated costs for this month are $ESTIMATED_COST.  For more details, open the attached csv file with excel."

if [ -f $REPORTFILE ]; then
  rm -f $REPORTFILE
fi


if [ -f  $CSV_TARGET ]; then
  for TARGET in $TARGETS; do
    echo $BODY | sendEmail -f $FROMADDR -t $TARGET -u $SUBJECT -a $CSV_TARGET -s $MAIL_SERVER
    echo "mailed to $TARGET" >> $REPORTFILE 2>&1
    echo "" >> $REPORTFILE 2>&1
  done
else
  echo "failure to read report file for $COMPANYNAME" | mail $ADMINEMAIL -s 'aws cost report issues'
  echo "did not find $CSV_TARGET, cannot mail." >> $REPORTFILE
fi
