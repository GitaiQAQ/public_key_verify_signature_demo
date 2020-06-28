NAME		:= rsa-verify
obj-m		:= $(NAME).o
# KDIR 		:= /lib/modules/$(shell uname -r)/build
KDIR 		:= /lib/modules/4.19.126/build
# KDIR 		:= /lib/modules/4.15.0-30deepin-generic/build

all: sign.h
	make -C $(KDIR) M=$(PWD) modules  

clean:
	make -C $(KDIR) M=$(PWD) clean

privkey.pem:
	# openssl genrsa -out privkey.pem 1024
	echo ********

pubkey.cer: privkey.pem
	# openssl rsa -outform DER -pubout -in privkey.pem -out pubkey.cer
	echo ********

sign.h: pubkey.cer hello.sha256 hello.sig
	# https://stackoverflow.com/questions/41084118/crypto-akcipher-set-pub-key-in-kernel-asymmetric-crypto-always-returns-error
	openssl asn1parse -in pubkey.cer -inform DER -strparse 24
	xxd -s 24 -i pubkey.cer > sign.h
	echo "unsigned char hello_sha256[] = {" >> sign.h
	xxd -r -ps hello.sha256 | xxd -i >> sign.h
	echo "};" >> sign.h
	echo "unsigned char hello_sig[] = {" >> sign.h
	xxd -r -ps hello.sig | xxd -i >> sign.h
	echo "};" >> sign.h

hello.sha256:
	# echo -n $$(cat hello | sha256sum | cut -d ' ' -f 1) | xxd -r -ps > hello.sha256
	echo *****************

hello.sig: privkey.pem hello.sha256
	# -encrypt  -sign
	# openssl rsautl -sign -inkey privkey.pem -in hello -out hello.sig
	echo *****************

clean-files += hello hello.sig hello.sha256  pubkey.cer pubkey.pem sign.h