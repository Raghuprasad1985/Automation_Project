#! /bin/bash

#Declaring Variables
raghuprasadS3Bucket="upgrad-raghuprasad"

raghuprasadTARFileName='Raghuprasad-httpd-logs-'$(date '+%d%m%Y-%H%M%S')'.tar'

#End of declaring variables


#To install latest updates in ubuntu server

sudo apt update -y

# End of latest updates

#To check if Apache2 is already installed
#If installed do nothing otherwise install it in ubuntu server

if ( dpkg -s apache2  >/dev/null 2>&1 ) then
        echo "Package is installed"
else
        echo "Package is not installed"
        sudo apt install apache2 -y
fi

#End of Apache2 status check and installation (if required)

#To check if Apache2 service is enabled
#If not enabled then we need to enable it. So, when server restart it will auto run

if systemctl list-unit-files --state=enabled | grep apache2; then
        echo "Service is enabled"
else
        echo "Service is not enabled"
        sudo systemctl enable apache2
fi

#End of service enable

#To check if Apache2 service is running

if systemctl is-active --quiet apache2; then
        echo "Apache2 service running"
else
	 echo "Apache2 service not running"
        sudo systemctl start apache2
fi

#End of service check

#To create TAR file

#Creating file

#Creating folder name
folderName='tmp'

#Checking if folder already exists
if [ -d $folderName ]
then
        echo 'Folder exists'
else
        echo 'Foder does not exists'
        mkdir $folderName
fi

cd "${folderName}"

#Creating TAR file

tar -cvf "${raghuprasadTARFileName}" /var/log/apache2/*.log
#End of TAR file creation

#Upload TAR file to S3 bucket

aws s3 \
cp ${raghuprasadTARFileName} \
s3://${raghuprasadS3Bucket}/${raghuprasadTARFileName}

#End of TAR file upload to S3 bucket

#To log file upload details Inventory.html for Book Keeping

fileSize=$(ls -sh $raghuprasadTARFileName | awk '{print $1}')

cd /var/www/html
pwd

inventoryFile="inventory.html"

if [ -e $inventoryFile ]; then
        echo "File already exists"
else
        echo "Creating a file"
        sudo touch $inventoryFile
        sudo chmod 777 $inventoryFile -R
        printf "%s\n"  "<b> Log Type&emsp;&emsp;Time Created&emsp;&emsp;&emsp;&emsp;Type&emsp;&emsp;Size</b> <br/><br/>" > $inventoryFile
fi

printf "%s\n"  "httpd-logs&emsp;&emsp;$(date '+%d%m%Y-%H%M%S')&emsp;&emsp;&emsp;tar&emsp;&emsp;${fileSize} <br/>" >> $inventoryFile


#End of Book Keeping

#Creation Cron Job

checkForCronJob=$(sudo crontab -l || echo "")
if [ $checkForCronJob == ""]; then
        echo "Creating cron job"
        cronFileName="automation.sh"
        cd /etc/cron.d/
        sudo touch $cronFileName
	new_job="0 20 * * * /root/Automation_Project/automation.sh"
        sudo chmod 777 $cronFileName -R
        printf "$new_job" > $cronFileName
        #echo $cronFileName | sudo crontab
        (echo "$new_job") | sort - | uniq - | sudo  crontab -
else
        echo "Cron job alread exists"
fi

#End of Cron Job creation

