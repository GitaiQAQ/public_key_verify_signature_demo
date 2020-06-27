/*
 * @Author: Gitai<i@gitai.me>
 * @Date: 2020-06-26 18:07:59
 * @LastEditors: Gitai
 * @LastEditTime: 2020-06-28 00:00:32
 * @FilePath: /src/rsa/rsa-verify.c
 */
/*
 * @Author: Gitai<i@gitai.me>
 * @Date: 2020-06-26 18:07:59
 * @LastEditors: Gitai
 * @LastEditTime: 2020-06-27 10:35:14
 * @FilePath: /src/rsa/rsa-verify.c
 */
#include <linux/init.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/kernel.h>
#include <linux/kprobes.h>
#include <linux/binfmts.h>
#include <linux/proc_fs.h>
#include <linux/lru_cache.h>
#include <crypto/public_key.h>
#include <linux/types.h>
#include <linux/cred.h>
#include <crypto/hash.h>
#include <crypto/sha.h>
#include <crypto/algapi.h>
#include "sign.h"

MODULE_LICENSE("GPL");

/*
 * Verify the signature on a module.
 */
int rsa_verify(u8 *hash, u8 hash_len, u8 *signature_bytes, u32 signature_bytes_len)
{
    struct public_key rsa_pub_key = {
        .key = pubkey_cer,
        .keylen = (u32)(sizeof(pubkey_cer)),
        .pkey_algo = "rsa",
        .id_type = "X509"};

    struct public_key_signature sig = {
        .s = signature_bytes,
        .s_size = signature_bytes_len,
        .digest = hash,
        .digest_size = hash_len,
        .pkey_algo = "rsa",
        .hash_algo = "sha256"};

    int error = public_key_verify_signature(&rsa_pub_key, &sig);
    if (error)
    {
        pr_info("error verifying. error %d\n", error);
        return error;
    }

    pr_info("verified successfuly!!!\n");
    return 0;
}

int int_module(void)
{
    printk(KERN_INFO "Hello rsa-verify\n");
    void *sig = kmalloc(sizeof(hello_sig), GFP_KERNEL);
    memcpy(sig, hello_sig, sizeof(hello_sig));
    return rsa_verify(hello_sha1, sizeof(hello_sha1), sig, sizeof(hello_sig));
}

void clanup_module(void)
{
    printk(KERN_INFO "Goodbye rsa-verify\n");
}
module_init(int_module);
module_exit(clanup_module);

MODULE_AUTHOR("Gitai");
MODULE_DESCRIPTION("ELF!\n");