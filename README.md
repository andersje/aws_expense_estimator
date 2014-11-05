aws_expense_estimator
=====================

A perl script intended to predict month-end AWS computing costs by extrapolating from expenses-to-date.  Note that the farther along in the month you are, the more accurate this will be.

This code is distributed under the GPLv3.  All copyrights held by Andersand Corporation, but honestly, I don't know why you'd want to pirate this anyway. 

There are two prerequisites packages to succesfully running this script.

0) Tim Kay's AWS tools
   These can be obtained from http://timkay.com/aws/ -- simply follow his instructions, to get this script

1) the sendEmail command
   On Ubuntu, you can get this with:
      sudo apt-get install sendemail

Next, you'll need to follow some configuration steps to get this working.

0) you'll need to ensure you've got enhanced billing turned on in AWS, and set to save in a specific bucket.  See http://aws.amazon.com/about-aws/whats-new/2012/06/05/aws-billing-enables-enhanced-csv-reports-and-programmatic-access/ and http://docs.aws.amazon.com/awsaccountbilling/latest/about/programaccess.html  for more information.

1) create a dedicated user to run the report and mail it out.  I made one called "awsreporter", and didn't give it a pubkey OR a password, so it can't be logged into.  But it can run cronjobs.  In my mind, this is more intuitively obvious than having it run under root (which is more authority than ANY of these scripts need), or a regular user account (which you may wish to delete if that user leaves the company).

2) fire up a shell as your dedicated report user

3) login to your S3 bucket and ensure you can see that file.

4) create your ~/.awssecret file, according to the format spelled out on timkay's page above.

5) test your awstool installation, and ensure you can list the contents of your bucket, and actually fetch the file

6) Now, test the sendEmail program by sending yourself a message:

       sendEmail -f root@yourhostname -t targetemailaddress@yourdomain.com -u MyTestMessage -m "this is the message body" -s yourSMTPserver.yourdomain.com

7) copy ini/estimator.dist to ~/.estimator.ini, and edit it appropriately.

8) install the binaries:

       cp -a bin ~/

9) test bin/report_wrapper.bash, ensure it actually works:

       ~/bin/report_wrapper.bash

10) add the following cron entry to your report user's crontab:

       15 06 * * 3  /path/to/report_wrapper.bash > /dev/null 2>/dev/null 
       ## that'll cause it to run every wednesday, at 06:15 hours

11) profit.



That should get you up and running.  As always, issues/bug reports are appreciated.  I might even add features if you need.  I just haven't thought of anything I really needed to add to this project.
