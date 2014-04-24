aws_expense_estimator
=====================

A perl script intended to predict month-end AWS computing costs by extrapolating from expenses-to-date.  Note that the farther along in the month you are, the more accurate this will be.

This code is distributed under the GPLv3.  All copyrights held by Andersand Corporation, but honestly, I don't know why you'd want to pirate this anyway. 

There are several prerequisites packages to succesfully running this script.

0) Tim Kay's AWS tools
   These can be obtained from http://timkay.com/aws/ -- simply follow his instructions, to get this script

1) the sendEmail command
   On Ubuntu, you can get this with:
      sudo apt-get install sendemail

2) the perl text-csv library
   You can install via CPAN or, on Ubuntu, you can get this via apt-get:
      sudo apt-get install libtext-csv-encoded-perl

Next, you'll need to follow some configuration steps to get this working.

0) create a dedicated user to run the report and mail it out.  I made one called "awsreporter", and didn't give it a pubkey OR a password, so it can't be logged into.  But it can run cronjobs.  In my mind, this is more intuitively obvious than having it run under root (which is more authority than ANY of these scripts need), or a regular user account (which you may wish to delete if that user leaves the company).

1) you'll need to ensure you've got enhanced billing turned on in AWS, and set to save in a specific bucket.  See http://aws.amazon.com/about-aws/whats-new/2012/06/05/aws-billing-enables-enhanced-csv-reports-and-programmatic-access/ and http://docs.aws.amazon.com/awsaccountbilling/latest/about/programaccess.html  for more information.

2) login to your S3 bucket and ensure you can see that file.

3) create your ~/.awssecret file, according to the format spelled out on timkay's page above.

3) test your awstool installation, and ensure you can list the contents of your bucket, and actually fetch the file

4) Now, test the sendEmail program but sending yourself a message:

       sendEmail -f root@yourhostname -t targetemailaddress@yourdomain.com -u MyTestMessage -m "this is the message body" -s yourSMTPserver.yourdomain.com

5) edit bin/getbillingfile.sh, set your homedirectory and your bucket name appropriately

6) test bin/getbillingfile.sh, ensure it works.

7) edit bin/csv_report_generator.pl, set your homedirectory.  That's all that needs to be changed

8) test bin/csv_report_generator.pl, ensure it works.

9) edit bin/mailit_attachment.sh, change those five variables.  

10) test bin/mailit_attachment.sh, ensure it actually works

11) following the example contained in crontab/sample-user, put cron entries in place.  Be sure to change YOURREPORTUSER to the actual name of your report user.

12) profit.
