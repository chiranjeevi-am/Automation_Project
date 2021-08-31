sudo apt update -y
pkg_name=apache2

dpkg -s $pkg_name &> /dev/null

if [ $? -ne 0 ]
then
        echo "apache2 not installed.Hence, Installing it..."
        sudo apt-get install $pkg_name -y
else
        echo "apache2 installed"
fi

systemctl is-active --quiet apache2

if [ $? -ne 0 ]
then
        echo "apache2 service not running, Starting the service..."
        systemctl start --quiet apache2
        echo "apache2 service started"
else
        echo "apache2 service already running"
fi

systemctl is-enabled --quiet apache2

if [ $? -ne 0 ]
then
        echo "apache2 service not enabled, Enabling the service..."
        systemctl enable --quiet apache2
        echo "apache2 service enabled"
else
        echo "apache2 service already enabled"
fi

myname=chiranjeevi
timestamp=$(date '+%d%m%Y-%H%M%S')
s3_bucket=upgrad-chiranjeevi

tar cvf /tmp/${myname}-httpd-logs-${timestamp}.tar -P /var/log/apache2/*.log

aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

size=$(du -sh /tmp/${myname}-httpd-logs-${timestamp}.tar | cut -c 1-3)

if [ ! -e /var/www/html/inventory.html ]
then
        echo "<!DOCTYPE html>
        <html>
        <head>
        <title>My_webpage</title>
        </head>
        <body>
        <h2>&emsp;&emsp;&emsp;Log Type&emsp;&emsp;&emsp;Time Created&emsp;&emsp;&emsp;Type&emsp;&emsp;&emsp;Size</h2>" > /var/www/html/inventory.html

else
	echo "<p style='font-size:23px'>&emsp;&emsp;&emsp;httpd-logs&emsp;&emsp;&emsp;${timestamp}&emsp;&emsp;&emsp;tar&emsp;&emsp;&emsp;${size}</p>" >> /var/www/html/inventory.html
fi

chmod +x /root/Automation_Project/automation.sh
if [ ! -e /etc/cron.d/automation ]
then
        echo "0 9 * * * root /root/Automation_Project/automation.sh" >> /etc/cron.d/automation
else
        echo "cron job scheduled already"
fi
