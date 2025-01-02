# ReverseSSH

Je pense que l'erreur vient du fait que ta commande fonctionne quand tu es dans un terminal car elle "a" un terminal.

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

Tu ne mets pas de mot de passe à la clé, c'est déjà suffisamment secure.

(au pire il existe la possibilité de lancer un agent ssh au démarrage de ton raspberry pi)

Et ensuite tu envois cette clé sur ton serveur :

```shell
user@rasp $ ssh-copy-id user@server_IP
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/user/.ssh/id_rsa.pub"

```

Pof ! Plus de sshpass à la kon

Enfin je suis plus à l'aise avec une configuration ssh_config, qu'avec une ligne de commande :

Voir le fichier [ssh.config](./ssh.config)

```ssh
Host montunnel
  Hostname <Server_IP>
  User user
  SessionType                                  #  -N
  RequestTTY no                                #  -T
  ForkAfterAuthentication yes                  #  -f (inutile car tu mets ton service en "type simple")
  RemoteForward localhost:10027 localhost:22   #  -R    
```

Qui correspond à la commande

```shell
ssh -N -T -f -R 10027:127.0.0.1:22 user@server_IP   # Pour un type forking
ssh -N -T -R 10027:127.0.0.1:22 user@server_IP      # Pour un type simple
```

> Pour les types de service systemd
> voir : <https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html#Type=>

Tu peux utiliser ce fichier ssh.config comme ceci :

```shell
ssh -F ssh.config montunnel
```

## Créer le service

```shell
sudo systemctl edit --force --full remotessh.service # Permet de créer le service "remotessh"

|   # Entrée dans un éditeur de texte (nano ou vim)
| [Unit]
| Description=Reverse SSH Tunnel
| After=network-online.target
| Wants=network-online.target
|  
| [Service]
| Type=simple
| ExecStart=/usr/bin/ssh -F /root/ssh.config montunnel
| Restart=on-failure
| 
| [Install]
| WantedBy=multi-user.target

|   # à la fin de l'édition on quitte

sudo systemctl enable remotessh.service
sudo systemctl start remotessh.service
sudo systemctl status remotessh.service
remotessh.service - Reverse SSH Tunnel
     Loaded: loaded (/etc/systemd/system/remotessh.service; enabled; preset: enabled)
     Active: active (running) since Thu 2025-01-02 22:28:59 CET; 6min ago
   Main PID: 92324 (ssh)
      Tasks: 1 (limit: 18741)
     Memory: 1.4M (peak: 1.8M)
        CPU: 142ms
     CGroup: /system.slice/remotessh.service
             └─92324 /usr/bin/ssh -F /root/ssh.config montunnel

janv. 02 22:28:59 carniceria systemd[1]: Started remotessh.service - Reverse SSH Tunnel.

```

## Tester

Il ne reste plus qu'à tester le tunnel ...

Perso j'ai testé l'accès à mon serveur Cups,

en lançant cette remote depuis mon pc vers un conteneur incus :

```ssh-config
RemoteForward localhost:8000 localhost:631
```

```shell
$ incus shell etcdtest                   

root@etcdtest:~# curl localhost:8000 -I
HTTP/1.1 200 OK
Connection: Keep-Alive
Content-Language: fr_FR
Content-Length: 2340
Content-Type: text/html; charset=utf-8
Date: Thu, 02 Jan 2025 21:37:19 GMT
Keep-Alive: timeout=10
Last-Modified: Thu, 26 Sep 2024 11:15:36 GMT
Accept-Encoding: gzip, deflate, identity
Server: CUPS/2.4 IPP/2.1                            # J'ai bien accès à mon cups ...
X-Frame-Options: DENY
Content-Security-Policy: frame-ancestors 'none'
```
