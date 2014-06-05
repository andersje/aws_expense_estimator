#!/usr/bin/perl


# hacked up perl script to estimate monthly charges off of an AWS account
# copyright 2013, Andersand Corporation.  All rights reserved.
# now handles leap year and hours-in-month calculations properly

use Text::CSV;

if ($#ARGV ne "0") {
	print "sorry, I only know how to handle one argument.  You have to tell me where to save the csv file.  Dying\n";
	exit 1;
} else { $filename=$ARGV[0]; }

my @rows;
my $csv = Text::CSV->new ( { binary=>0} ) # don't need binary because we won't have embedded newlines.
        or die "Cannot use CSV: ".Text::CSV->error_diag();
open my $fh, $filename or die "$filename: $!";

my $DEBUG=0;
# set this to 1 to turn on debugging messages

my $total_projected=0;
# initialize total projected costs to zero

# print our header line for the report
print "\"category\",\"detailed_item\",  \"charges to date\", \"estimated total monthly cost\"\n";
## field number 19 is desc? -- see code which reads it in later
## field 22 is how many hours we've used it

sub monthly_hours($) {
	#subroutine to determine how many hours are in the current month.
	
	my $MONTH_NUM=$_[0];

	$MONTH_NUM =~ s/^0//g;
	#default to months being 31 days long
	my $hours=31*24;

	# I hate february -- it has arcane rules for whether
	# or not it has 28 or 29 days.
	# 28 days normally, 29 days in leapyears, but '00 years
	# are apparently never leap years, so february is 28 days then
	
	if ($MONTH_NUM eq 2) {
		#leap year nonsense
		$hours=28*24;
		my $year=`date +%Y`;
		if (($year % 400) eq 0) { $hours = 29*24; }
		elsif (($year % 100) eq 0){ $hours = 28*24; }
		## special case for century-end years
		elsif (($year % 4) eq 0) { $hours = 29*24; }

		## honestly, why can't we go to metric time?  
	}

	#this code determines which months have 30 days.
	if ($MONTH_NUM eq 4 || $MONTH_NUM eq 6 || $MONTH_NUM eq 9 || $MONTH_NUM eq 11) {
		$hours=30*24;
	}

	return $hours;

}

my $day=`date +%d`;  # get day-of-month from shell command
chomp $day;
my $num_hours_so_far=$day*24;

my $month=`date +%m`;
my $MONTHLY_HOURS=&monthly_hours($month);
# determine how many hours we expect to have in this month.


## now, we read in our CSV, line by line.
## we're really only interested in lines that are marked as 'payerlineitem'
##   or 'statementtotal'
## for those lines, we need the 2nd, 14th, 19th, 22nd fields -- remember
## perl starts counting fields at 0, which is the way it should be.

## I'm hoping the variable names tell you which field is which
while (my $row = $csv->getline( $fh ) ) {
        $category = $row->[3];
        if ( ($category =~ /(payerlineitem|statementtotal)/i) ) {
                $amount = $row->[-1];
                $item_desc = $row->[13];
                $detail_desc = $row->[18];
                $hours_used = $row->[21];
                if ($hours_used++ > 0) {
                        $average_hourly_cost = $amount/$num_hours_so_far;
			#this is the secret sauce for the cost intepretation
			# figure out how much we've spent so far, and 
			# assume that our usage pattern will exactly match
			# it going forward.
                } else {
			# if we haven't USED the service, we can't guess
			# at a usage pattern.
                        $average_hourly_cost = "N/A";
                }
                my $temp = $average_hourly_cost * $MONTHLY_HOURS;

		# round off to only two decimal places.  We're not 
		# de-orbiting a mars lander here, so we don't need super
		# precision
                $projected_monthly_cost = sprintf("%.2f", $temp);

                if ($projected_monthly_cost > 0) {
                ##      print "adding $projected_monthly_cost in\n";
                        $total_projected+=$projected_monthly_cost;

                }
                $amount =~ s/0*$//;
		#sometimes this field has a string of zeros in it, which
		# was messing me up.  Dump the terminal zeros.


		## only display items for which we have a cost.
                if ($amount > 0) {
                        if ( $item_desc eq '' ) {
                                $item_desc = "TOTAL";
                                my $temp = ($amount/$num_hours_so_far) * $MONTHLY_HOURS;
                                $projected_monthly_cost = sprintf("%.2f", $temp);

                        }
                        print "\"$item_desc\", \"$detail_desc\", \"\$" . $amount . "\", \"\$" . $projected_monthly_cost . "\" \n";

                        #print "$item_desc ($detail_desc) : \$" . $amount . ", \$" . $projected_monthly_cost . "\n";
                if ($DEBUG) { my $rowstr = $csv->string(); print "$rowstr"; }
                }

        }
}
close $fh;
print "\"total projected costs\",\"\",\"\",\"\$" . $total_projected . "\"\n";
##print " (please note, projected costs assume that the usage patterns up to the current time will continue until the end of the month.)\n";
