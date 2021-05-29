#! /bin/bash


#To install latest updates in ubuntu server

sudo apt update -y

# End of latest updates

#To check if Apache2 is already installed
#If installed do nothing otherwise install it in ubuntu server

if ( dpkg -s apache2  >/dev/null 2>&1 ) then
        echo "Package is installed"
else
        echo "Package is not installed"
        sudo apt install apache2
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
fileName='Raghuprasad-httpd-logs-'$(date '+%d%m%Y-%H%M%S')
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
pwd

#Creating TAR file

tar -cvf "${fileName}.tar" "/var/log/apache2"
#End of TAR file creation

#Upload TAR file to S3 bucket

raghuprasadS3Bucket="upgrad-raghuprasad"

aws s3 \
cp ${fileName}.tar \
s3://${raghuprasadS3Bucket}/${fileName}.tar

#End of TAR file upload to S3 bucket

