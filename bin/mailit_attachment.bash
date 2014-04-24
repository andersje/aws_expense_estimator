#!/bin/bash

### these are the variables you need to change.  Yes, I should read from an ini file.  Maybe someday.

HOMEDIR=/YOUR/HOMEDIR/MUST/GO/HERE
ADMINEMAIL="YOURADDRESS@YOURDOMAIN.COM"
TARGETS="ADDRESS_ONE@YOURDOMAIN.COM ADDRESS_TWO@YOURDOMAIN.COM ADDRESS_THREE@YOURDOMAIN.COM"
FROMADDR="SENDERADDRESS@YOURDOMAIN.COM"
MAIL_SERVER="YOURMAILSERVER.YOURDOMAIN.COM"
COMPANYNAME="YOURCOMPANYNAME"

### You should not need to change anything below this line


ESTIMATED_COST=$(tail -1 $SOURCEFILE | awk -F, '{print $NF}' | sed -e 's/\"//g')
SOURCEFILE=$HOMEDIR/curr_estimated.csv
SUBJECT="projected amazon costs for current month ($ESTIMATED_COST)"
BODY="At current, total estimated costs for this month are $ESTIMATED_COST.  For more details, open the attached csv file with excel."

if [ -f  $SOURCEFILE ]; then
	for TARGET in $TARGETS; do
		echo $BODY | sendEmail -f $FROMADDR -t $TARGET -u $SUBJECT -a $SOURCEFILE -s $MAIL_SERVER
	done
else
	echo "failure to read report file for $COMPANYNAME" | mail $ADMINEMAIL -s 'aws cost report issues'
fi
