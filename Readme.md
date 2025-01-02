# ReverseSSH

Je pense que l'erreur viens du fait que ta commande fonctionne quand tu es dans un terminal car elle "a" un terminal.

Il faut donc ajouter une option `-T`

```shell
ssh -N -T -R 10027:127.0.0.1:22 user@server_IP
```

Ensuite je suis contre l'utilisation de `sshpass`...

Tu peux très facilement créer une clé ssh sur ton raspberry

```shell
user@rassp $ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/user/.ssh/id_rsa): 
Created directory '/home/user/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/user/.ssh/id_rsa
Your public key has been saved in /home/user/.ssh/id_rsa.pub
(...)
```

Tu ne mets pas de mot de passe à la clé, c'est déjà suffisemment sécure.

(au pire il existe la possibilité de lancer un agent ssh au démarrage de ton raspeberry pi)

Et ensuite tu envois cette clé sur ton serveur :

```shell
user@rasp $ ssh-copy-id user@server_IP
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/user/.ssh/id_rsa.pub"

```

Pof ! Plus de sshpass à la kon

Enfin je suis plus à l'aise avec une configuration ssh_conf, qu'avec une ligne de commande :

Voir le fichier [ssh.config](./ssh.config)

```ssh
Hostname montunnel
  Host <Server_IP>
  User user
  SessionType                                  #  -N
  RequestTTY no                                #  -T
  ForkAfterAuthentication yes                  #  -f 
  RemoteForward localhost:10027 localhost:22   #  -R    
```

Qui correspond à la commande

```shell
ssh -N -T -f -R 10027:127.0.0.1:22 user@server_IP
```

Que tu peux utiliser comme ceci :

```shell
ssh -F ssh.config montunnel
```
