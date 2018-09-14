# Port-Crawler
Port scanning scripts powered by Masscan to provide functionality similar to Shodan by using Elasticsearch and Kibana as the web interface.

Currently only tested on Ubuntu 16.04.

## Credit:

This project is made possible by these other open source projects:

[Masscan](https://github.com/robertdavidgraham/masscan)

[Elasticsearch](https://github.com/elastic/elasticsearch)

[Kibana](https://github.com/elastic/kibana)

[jsonpyes](https://github.com/xros/jsonpyes)

[ThinGallery](https://github.com/gfwilliams/ThinGallery)



## Requirements:
Chrome must be installed on the host: [https://www.google.com/chrome/](https://www.google.com/chrome/)




## Installation on Ubuntu:

### Install Elasticsearch and Kibana:

Install Java:

```
sudo apt-get update
sudo apt-get install openjdk-8-jdk
```


Install the Elasticsearch repository:

```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
```


Install Elasticsearch:

```
sudo apt-get update
sudo apt-get install elasticsearch
```


Configure the Elasticsearch cluster with the name port-crawler:

```
sudo sed -i 's/#cluster.name: my-application/cluster.name: port-crawler/g' /etc/elasticsearch/elasticsearch.yml
```


Configure Elasticsearch to only be available via localhost:

```
sudo sed -i 's/#network.host: 192.168.0.1/network.host: 127.0.0.1/g' /etc/elasticsearch/elasticsearch.yml
```


Enable and start Elasticsearch:

```
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
```


Install Kibana:

```
sudo apt-get update
sudo apt-get install kibana
```


Bind Kibana to your hostname or IP address (replace 'ip-or-hostname' with your IP or hostname):

```
sudo sed -i 's/#server.host: "localhost"/server.host: "ip-or-hostname"/g' /etc/kibana/kibana.yml
```



Start and enable Kibana:

```
sudo systemctl enable kibana.service
sudo systemctl start kibana.service
```



### Install Masscan:

```
sudo apt-get install git gcc make clang libpcap-dev
sudo chown -R "$USER:$USER" /opt
cd /opt
git clone https://github.com/robertdavidgraham/masscan
cd masscan
make
sudo cp bin/masscan /usr/bin/
exit
```




### Install Jsonpyes:

```
sudo apt-get install python-pip
sudo pip install jsonpyes
```


### Install jq:

```
sudo apt-get update
sudo apt-get install jq
```


### Install Chromium (for taking screenshots of web services):

```
sudo apt-get update
sudo apt-get install chromium-browser
```

### Download Port-Crawler

```
sudo chown -R "$USER:$USER" /opt
cd /opt
git clone https://github.com/heywoodlh/Port-Crawler
cd Port-Crawler
```



### Configure scanner.sh

Edit `portfile.txt` to contain each port/port range that you would like to scan, comma separated.

Edit the variables in `scanner.sh` to fit your needs. 

Brief explanation of each variable:

`MASSCAN`: Should point to the `masscan` binary (`which masscan`)

`JSONPYES`: Should point to the `jsonpyes` binary (`which jsonpyes`)

`CHROME`: Should point to the `google-chrome` binary (`which google-chrome`)

`IP_RANGE`: IP addresses/ranges of IP addresses to be scanned by masscan 

`PORTFILE`: The location to portfile.txt

`SCREENSHOT_DIR`: the directory where you would like screenshots stored

`SCREENSHOT`: if set to 'true', will take screenshots of services running on port 80, 443 and 8080

`ELASTICSEARCH`: URL of Elasticsearch host

`ELASTICSEARCH_INDEX`: Name of the index that will be uploaded to Elasticsearch -- the default will append the date so that each index is unique according to the scan time

`BLANK_MASTER`: Path to a blank png to use if screenshots are blank (they will be deleted if they look identical to blank-master.png


If you wish the screenshots to be served as a gallery via a web server, refer to these variables:

`WEB_SERVER`: If set to true, gallery.html can be used to serve all the screenshot files as a nice web based gallery

`WEB_SERVER_USER`: Set this to the web server username, such as www-data for Apache2 on Ubuntu 


In order for the web gallery to work, the screenshots directory needs to be accessible from the web root of the web server (or configure your web server however you would prefer). On default Apache2 on Ubuntu, you could use a symlink in your web root directory by running this command from the repository directory:


`sudo ln -s ./screenshots /var/www/html/screenshots`


Once the script has been run you will be able to view your screenshots from a web based gallery on your server with the URL http://ip-or-hostname/screenshots/gallery.html.


### Run the script manually:

`./scanner.sh`


### Set the script to run as a cron at 1:00 a.m. every day:

Add this entry to your crontab (`crontab -e`):

`0 1 * * * /opt/Port-Crawler/scanner.sh`


## Additional Information:

`scanner.sh` was built with the intention to run as a cron job. In order to conserve disk space, it will not overwrite screenshots with the same name. I would recommend setting up a cronjob to remove the screenshots directory on a regular basis (perhaps a weekly basis) so that way the screenshots are refreshed periodically -- assuming you can afford the bandwidth.
