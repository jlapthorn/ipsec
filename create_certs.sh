#!/bin/bash

PREFIX=$(date +%Y%m%d%H%M%S)


if [ ! -f hosts.txt ]; then
	echo "You need to have a hosts.txt file with FQDN's of the servers you need certificates for"
	exit 1
fi


#Generate CA psuedo random password
CA_PASSPHRASE=$(openssl rand -base64 48)

echo "$(date) - ${PREFIX}: ${CA_PASSPHRASE}" >> CA_passphrase.txt 

#Create Root CA key
openssl genrsa -des3 -passout pass:${CA_PASSPHRASE} -out /etc/pki/CA/private/rootCA.key 4096

#Create Root CA certificate
openssl req -x509 -new -nodes -passin pass:${CA_PASSPHRASE} -key /etc/pki/CA/private/rootCA.key -sha256 -days 1024 -out /etc/pki/CA/certs/rootCA.crt -subj "/C=GB/ST=Berkshire/O=Lapthorn Consulting Ltd/CN=ca-test.lapthorn.example.com"

#
# The next steps are done for each host
#


while read hostname
do 

#Create key for host
openssl genrsa -passout pass:"" -out /etc/pki/tls/private/${hostname}.key 2048

#Create CSR for each host
openssl req -new -sha256 -key /etc/pki/tls/private/${hostname}.key -subj "/C=GB/ST=Berkshire/O=Lapthorn Consulting Ltd/CN=${hostname}" -out /etc/pki/tls/certs/${hostname}.csr


#Validate CSR
#openssl req -in /etc/pki/tls/certs/${hostname}.csr -noout -text


#Sign the cert with the Root CA
openssl x509 -req -in /etc/pki/tls/certs/${hostname}.csr -passin pass:${CA_PASSPHRASE} -CA /etc/pki/CA/certs/rootCA.crt -CAkey /etc/pki/CA/private/rootCA.key -CAcreateserial -out /etc/pki/tls/certs/${hostname}.crt -days 730 -sha256

#Valifate cert
#openssl x509 -in /etc/pki/tls/certs/${hostname}.crt -text -noout

if [ ! -d pkcs12_certs ];then
	mkdir pkcs12_certs
fi


#Convert to pkcs12
openssl pkcs12 -export  -in /etc/pki/tls/certs/${hostname}.crt  -inkey /etc/pki/tls/private/${hostname}.key   -certfile /etc/pki/CA/certs/rootCA.crt   -passout pass:   -out pkcs12_certs/${PREFIX}_${hostname}.p12

#Validate pkcs12 cert
#openssl pkcs12 -passin pass: -passout pass: -info -in ${hostname}.p12

#Tidy up RSA certs
rm -f /etc/pki/tls/certs/${hostname}.crt /etc/pki/tls/private/${hostname}.key /etc/pki/tls/certs/${hostname}.csr

done < hosts.txt

#Tidy up CA

rm -f /etc/pki/CA/private/rootCA.key /etc/pki/CA/certs/rootCA.crt
