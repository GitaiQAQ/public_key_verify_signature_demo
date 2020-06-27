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
	openssl genrsa -out privkey.pem 1024

pubkey.cer: privkey.pem
	openssl rsa -outform DER -pubout -in privkey.pem -out pubkey.cer
	openssl rsa -outform PEM -pubout -in privkey.pem -out pubkey.pem

sign.h: pubkey.cer hello.sha1 hello.sig
	# https://stackoverflow.com/questions/41084118/crypto-akcipher-set-pub-key-in-kernel-asymmetric-crypto-always-returns-error
	# 512 => 20
	# 1024 => 22
	# 2048 => 24
	openssl asn1parse -in pubkey.cer -inform DER -strparse 22
	xxd -s 22 -i pubkey.cer > sign.h
	xxd -i hello.sha1 >> sign.h
	xxd -i hello.sig >> sign.h

hello:
	echo -n hello > hello

hello.sha1: hello
	echo -n $$(cat hello | sha1sum | cut -d ' ' -f 1) | xxd -r -ps > hello.sha1

hello.sig: privkey.pem hello.sha1
	# -encrypt  -sign
	openssl rsautl -sign -inkey privkey.pem -in hello -out hello.sig

clean-files += hello hello.sig hello.sha1  pubkey.cer pubkey.pem sign.h