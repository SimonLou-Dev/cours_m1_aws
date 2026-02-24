sudo dnf install httpd-tools

ab -t 100000 -c 100 http://nginx-elb.nginx-app/