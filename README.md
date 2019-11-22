# Create pkcs12 certificates from a self signed CA

Place a list of FQDN for servers you need a pkcs12 certificate for in the hosts.txt file.

then run `bash create_certs.sh`

This will generate a CA placing the key passphrase in CA_Passphrase.txt prefixed with date and time.

It will then generate Keys, CSR's and signed certificates for each hostname and convert them to pkcs12 certificates and store them in the pkcs12_certs directory prefixed with the same date and time linked to the CA passphrase.


All un needed certs and CA collateral are rmeoved when complete
