#!/usr/bin/perl


# hacked up perl script to estimate monthly charges off of an AWS account
# copyright 2013, Andersand Corporation.  All rights reserved.
# now handles leap year and hours-in-month calculations properly

use Text::CSV

my $homedir=/YOUR/HOMEDIR/MUST/GO/HERE

## no changes needed below this line.

my @rows;
my $csv = Text::CSV->new ( { binary=>0} ) # don't need binary because we won't have embedded newlines.
        or die "Cannot use CSV: ".Text::CSV->error_diag();
my $filename="/$homedir/billing.csv";
open my $fh, $filename or die "$filename: $!";

my $DEBUG=0;
my $total_projected=0;

#open my $fh, "<:encoding(utf8)","test.csv" or die "test.csv: $!";

#print "category (detailed_item):  charges to date, estimated total monthly cost\n";

print "\"category\",\"detailed_item\",  \"charges to date\", \"estimated total monthly cost\"\n";
## 19 is desc?
## 22 is how many hours we've used it

sub monthly_hours($) {
	my $MONTH_NUM=$_[0];

	$MONTH_NUM =~ s/^0//g;
	my $hours=31*24;

	if ($MONTH_NUM eq 2) {
		#leap year nonsense
		$hours=28*24;
		my $year=`date +%Y`;
		if (($year % 400) eq 0) { $hours = 29*24; }
		elsif (($year % 100) eq 0){ $hours = 28*24; }
		elsif (($year % 4) eq 0) { $hours = 29*24; }
		# I hate februay

	}

	if ($MONTH_NUM eq 4 || $MONTH_NUM eq 6 || $MONTH_NUM eq 9 || $MONTH_NUM eq 11) {
		$hours=30*24;
	}

	return $hours;

}

my $day=`date +%d`;
chomp $day;
my $num_hours_so_far=$day*24;

my $month=`date +%m`;
my $MONTHLY_HOURS=&monthly_hours($month);

while (my $row = $csv->getline( $fh ) ) {
        $category = $row->[3];
        if ( ($category =~ /(payerlineitem|statementtotal)/i) ) {
                $amount = $row->[-1];
                $item_desc = $row->[13];
                $detail_desc = $row->[18];
                $hours_used = $row->[21];
                ##print "WE HAVE USED THIS $hours_used\n";
                if ($hours_used++ > 0) {
                        $average_hourly_cost = $amount/$num_hours_so_far;
                } else {
                        $average_hourly_cost = "N/A";
                }
                my $temp = $average_hourly_cost * $MONTHLY_HOURS;
                $projected_monthly_cost = sprintf("%.2f", $temp);
                if ($projected_monthly_cost > 0) {
                ##      print "adding $projected_monthly_cost in\n";
                        $total_projected+=$projected_monthly_cost;

                }
                $amount =~ s/0*$//;
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
