#!/bin/sh
if [ ! -f ca.pem ] && [ ! -f ca_key.pem ]; then
  echo "Generating CA keys"
  openssl genpkey -algorithm RSA -out ca_key.pem -pkeyopt rsa_keygen_bits:2048
  openssl req -new -nodes -x509 -subj "/C=DE/ST=NRW/L=Bochum/O=RUB/OU=NDS" -key ca_key.pem -out ca.pem
fi
if [ ! -f rsa2048cert.pem ] && [ ! -f rsa2048key.pem ]; then
  echo "Generating RSA keys"
  openssl genpkey -algorithm RSA -out rsa2048key.pem -pkeyopt rsa_keygen_bits:2048
  openssl req -new -nodes -subj "/C=DE/ST=NRW/L=Bochum/O=RUB/OU=NDS/CN=example.com" -key rsa2048key.pem -out rsa2048cert.csr
  openssl x509 -req -in rsa2048cert.csr -CA ca.pem -CAkey ca_key.pem -CAcreateserial -out rsa2048cert.pem -days 1024
fi
if [ ! -f ec256cert.pem ] && [ ! -f ec256key.pem ]; then
  echo "Generating EC keys"
  openssl genpkey -algorithm EC -out ec256key.pem -pkeyopt ec_paramgen_curve:P-256 -pkeyopt ec_param_enc:named_curve
  openssl req -new -nodes -subj "/C=DE/ST=NRW/L=Bochum/O=RUB/OU=NDS/CN=example.com" -key ec256key.pem -out ec256cert.csr
  openssl x509 -req -in ec256cert.csr -CA ca.pem -CAkey ca_key.pem -CAcreateserial -out ec256cert.pem -days 1024
fi
if [ ! -f dh.pem ]; then
  echo "Creating DH parameters"
  openssl dhparam -out dh.pem 2048
fi
if [ ! -d db ]; then
  echo "Creating db"
  mkdir db
  openssl pkcs12 -export -in rsa2048cert.pem -inkey rsa2048key.pem -out rsa2048.p12 -name cert
  echo "Importing RSA key"
  pk12util -i rsa2048.p12 -d db
  openssl pkcs12 -export -in ec256cert.pem -inkey ec256key.pem -out ec256.p12 -name cert
  echo "Importing EC key"
  pk12util -i ec256.p12 -d db
fi
if [ ! -f server.jks ]; then
  echo "Creating Java keystore"
  keytool -importkeystore -srckeystore rsa2048.p12 -srcstoretype pkcs12 -destkeystore rsa2048.jks -deststoretype jks
  keytool -importkeystore -srckeystore ec256.p12 -srcstoretype pkcs12 -destkeystore ec256.jks -deststoretype jks
fi
#use test-ca from rustls
if [ ! -d test-ca ]; then
  curl -L https://github.com/ctz/rustls/tarball/master | tar zx --wildcards  --strip-components=1 '*/test-ca/'
fi

docker volume remove cert-data
docker volume create cert-data
docker run --rm -v cert-data:/cert/ -v $(pwd):/src/ busybox \
  cp -r /src/cert.pem /src/key.pem /src/ca.pem /src/ca_key.pem /src/dh.pem /src/db/ /src/test-ca/ /cert/
