#! /bin/sh
gzip -c --best /var/log/system.log > random.dat
openssl rand -rand file:random.dat 0
openssl req  -config $1 -keyout $2 -newkey rsa:1024 -nodes -x509 -days 365 -out $3