name='arbin'
logformat='httpd-logs'
timestamp=$(date '+%d%m%Y-%H%M%S') 
type='tar'

sudo apt update -y

echo  "-------Apache installed or not"
which apache2
if [[ $? == 0 ]]
then
	echo "Apache already installed"

else
	sudo apt install apache2 -y
	echo "Installed Apache now"
fi


echo "----- running or not ----------"


if [[ $(systemctl status apache2 | grep -i Running | awk '{print $3}') == '(running)' ]]
then
	echo "Already running"
else
	systemctl restart apache2
	echo "restarting the apache2"
fi

echo "----enabled or not----"


if [[ $(systemctl list-unit-files |grep apache2.service |awk '{ print $2}') == "enabled" ]] 
then
	echo "enabled"
else
	echo "enabling"
	systemctl enable apache2
fi

echo "-------- making tar -------------------"

cd /var/log/apache2 && tar -cvf $name-$logformat-${timestamp}.$type *.log &&  
mv $name-$logformat-${timestamp}.$type /tmp


aws s3 	cp /tmp/$name-$logformat-${timestamp}.$type  s3://s3-arbin/arbin/$name-$logformat-${timestamp}.$type



