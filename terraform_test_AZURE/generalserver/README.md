# TEST GENERAL SERVER

Deploy and test the generalserver module.

## Configure
- Enable AZURE credentials before launch terraform commands
```
  export ARM_SUBSCRIPTION_ID=XXXXXXX
  export ARM_CLIENT_ID=XXXXXXX
  export ARM_CLIENT_SECRET=XXXXXXX
  export ARM_TENANT_ID=XXXXXXX
```
- Create your id_rsa key if you want to add ssh_key variable (see https://www.ssh.com/ssh/keygen/)
- Create your own image reference on Azure or with Packer
