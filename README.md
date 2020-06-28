<!--
 * @Author: Gitai<i@gitai.me>
 * @Date: 2020-06-26 21:59:42
 * @LastEditors: Gitai
 * @LastEditTime: 2020-06-28 10:13:14
 * @FilePath: /src/rsa/README.md
--> 
openssl genrsa -out privkey.pem 512
openssl rsa -outform PEM -pubout -in privkey.pem -out pubkey.pem
openssl rsa -outform DER -pubout -in privkey.pem -out pubkey.cer

openssl asn1parse -in pubkey.cer -inform DER -strparse 22 
xxd -i pubkey.cer 

openssl rsautl -encrypt -in hello -inkey pubkey.cer -pubin -out hello.en
openssl rsautl -decrypt -in hello.en -inkey cakey.pem -out hello.de

openssl rsautl -sign -inkey privkey.pem -in hello -out hello.sig
openssl rsautl -verify -inkey pubkey.pem -pubin -in hello.sig

https://stackoverflow.com/questions/41084118/crypto-akcipher-set-pub-key-in-kernel-asymmetric-crypto-always-returns-error

https://stackoverflow.com/questions/42955989/why-public-key-verify-signature-returns-error-if-signature-buffer-is-defined-i

https://github.com/GitaiQAQ/signelf/blob/a946570b5a42dc303dfcf32b6e5b5ec089175fd2

关键点：
openssl rsautil -sign 生成的签名有问题

1. 应该直接调用 RSA_sign 方法
2. 公钥要转化成内核公钥的结构
    a. openssl asn1parse -in pubkey.cer -inform DER -strparse 22
    b. xxd -s 22 -i pubkey.cer > sign.h