# Pasos para la configuracion de red

## Firewall

Le agrego a la máquina de Firewall en VirtualBox, 2 adaptadores de red a red interna y cambio el que tiene por un "puente".
`/etc/network/interfaces` Muestra las configuraciones de las conexiones,  en principio solo muestra la enp0s3 (eth0).
En este archivo, le agrego la nueva dirección estática que voy a usar, que va a ser la enp0s8 agregandole address y network.
Con el comando `ifup enp0s8`, levanto la nueva configuración que agregue.
Ahora cuando reviso con `ifconfig` va a aparecer configurada.
Lo mismo con la segunda red `enp0s9`.

Cambio en `/etc/sysctl.conf` el valor de net.ipv4.ip_forward por 1 para habilitar el ip forwarding.

Con el comando de `iptables -L` me fijo las policies de los filtros y hago el default de cada una sea DROP con el comando `iptables -P <filter> DROP`.

Agreogo la configuracion en loopback

```
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
```

Agrego la dirección ip del cliente 02 para que pueda comunicarse con el firewall con los comandos:

```
iptables -A INPUT -m state --state NEW,ESTABLISHED,RELATED --source 192.168.20.2 -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -m state --state NEW,ESTABLISHED,RELATED -p tcp --dport 22 -j DROP
iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
```

Siendo el primero para aceptar la conexion ssh desde el cliente-02, el segundo para bloquear el resto de las conexiones y el ultimo habilita las respuestas del firewall al cliente-02 una vez establecida la conexion.

Para que el cliente 03 tenga acceso a internet, primero agrego el nateo de la red enp0s3 para que pueda hacer postrouting de las conexiones, despues agrego el FORWARD desde y hacia la ip del cliente 03 y la red enp0s3 (que es la dhcp). Los comandos son:

```
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
iptables -A FORWARD -i enp0s3 -d 192.168.20.3 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i enp0s9 -s 192.168.20.3 –o enp0s3 -j ACCEPT
```

Ademas, en el cliente 03 agrego como ruta default la ip 192.168.20.1 con el comando:

```
ip route add default via 192.168.20.1
```
O agregado el gateway en el archivo de configuracion de ubuntu.




Para que pueda comunicarse el cliente-04 con el webserver, agrego la regla:

```
iptables -A FORWARD -i 192.168.20.4 -o 192.168.10.3 -j ACCEPT
```

Para que se guarde, uso `iptables-save > /etc/firewall.conf` y creo un script para que se haga el restore de las reglas en `/etc/network/if-up.d/iptables` y le doy permisos de ejecución.


## Web server

Con WinSCP y logueandome con el user web-server, me conecte por ip para mover la jdk y el tomcat.
Descomprimi los archivos con `tar xzvf <archivo.tar.gz>` y los moví con `sudo mv <carpeta> /opt/`
Agregue la variable de Java al path de bash.

Configuro Tomcat (siguiendo esta [guia](https://kifarunix.com/install-apache-tomcat-9-on-debian-10-debian-9/)), agregando las variables de ambiente de CATALINA_HOME.
Agrego el user admin a la configuración del Tomcat en el xml de `tomcat-users.xml`.
Agrego la IP del cliente 04 para que se pueda comunicar con tomcat.

Hago el deploy de la app con el script de startup.sh en /bin/. Entrando desde otra VM (cliente-dmz), y accediendo desde el firefox a la IP:8080, se ve la página de tomcat.

Luego de hacer un shutdown con el sh correspondiente, muevo el `sample.war` a la carpeta de `webapps` en la carpeta de tomcat y ejecuto de nuevo el startup.sh.
Yendo a IP:8080/sample se puede ver la app que se deployo en la carpeta de webapps.

Por último, cambio la dirección ip a la 192.168.10.1


## Cliente-dmz

Cambio la configuración de de red para que sea una conexion puente y después cambio su ip para que sea 192.168.10.2


## Servidor DHCP

Instalo dhcp-server siguiendo la guia basica, cambiando el `INTERFACESv4="eth1"` por `INTERFACESv4="enp0s3"` por la versión 10 de Debian. Cambio su ip para que sea 192.168.20.254.
En el archivo de configuración (/etc/dhcp/dhcpd.conf), creo una subnet y agrego los rangos para que sean entre 192.168.20.101 y 192.168.20.110, y tambien agrego el router en 192.168.20.0


## File Server

En la configuración de VirtualBox, agrego un nuevo disco al file-server. Haciendo `fdisk - l` lo puedo ver ya en Linux y tengo que agregarle el punto donde se monta en /media/disco_backups. Para ello, primero lo configuro con el comando `fdisk /dev/sdb` y creo la partición sdb1 en el disco, a la que después la configuro como `ext4` con el comando `mkfs -t ext4 /dev/sdb1`. Por último, agrego el UUID y el punto de montaje en el archivo de `fstables`.

Creo el cron job con el comando `crontab -e`, agregando una linea que indica que se ejecuta todos los dias a las 18hs:

`0 18 * * * /backup_home_cliente-03.sh`

([guia](https://vitux.com/how-to-setup-a-cron-job-in-debian-10/))

Para poder guardar los archivos con rsync, cambie los permisos de /media/disco_backups para que tenga acceso el rsync.
Agrego tambien las keys de ssh para que no pregunte por la contraseña cada vez que se ejecute el archivo, utilizando el ssh-agent tanto en cliente como servidor.

## Cliente-03

Instalo Ubuntu 20.04 LTS y agrego openssh-server para poder conectarme desde el file server. Cambio la configuracion de red para que tenga la ip estatica 192.168.20.3 (siguiendo [esta](https://linuxize.com/post/how-to-configure-static-ip-address-on-ubuntu-20-04/) guia).

### LVM

Aplicaria LVM en el FIle Server para poder agregar más discos de backup en caso de quererlo. De esta forma el LVM se encargaria de administrar los backups de los archivos e incluso podria agregarle más seguridad al encriptarlo. Solo haría que los backups pertenezcan al LVM ya que no es necesario que el OS tambien este dentro del volumen en este caso.

- Desmonto el disco en /media/disco_backups `umount /media/disco_backups`
- Creo el Physical Volume con el comando `sudo pvcreate /dev/sdb1`
- Creo el Volume Group con `sudo vgcreate vhd1 /dev/sdb1`
- Creo el Logical Volume con `sudo lvcreate -n ext4-var -L 1020m vhd1`, siendo los ultimos 2 el tamaño del volume group (1020MiB) y el nombre del volume group
- Agrego el file system al logical volume `sudo mkfs -t ext4 /dev/vhd1/ext4-var`
- Cambio en el archivo /etc/fstab el UUID por el nuevo generado para el filesystem
- Vuelvo a montar el disco y le doy permisos de ejecucion para que el rsync funcione
- Con el comando `sudo vgdisplay` puedo ver el Volume Group creado

[guia de LVM](https://howto.biapy.com/en/debian-gnu-linux/system/setup/setup-and-use-the-logical-volume-manager-lvm-on-debian)
