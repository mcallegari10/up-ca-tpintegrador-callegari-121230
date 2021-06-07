#! /bin/bash

timestamp=`date +%Y-%m-%d_%H-%M-%S%Z`

if [ ! -d "./logs" ]; then
  mkdir logs
fi

touch ./logs/backup_home_cliente-03.sj_$timestamp.log
logfile="./logs/backup_home_cliente-03.sj_${timestamp}.log"

echo "Archivo de log creado" >> $logfile

if ping -c 1 -W 1 192.168.20.3; then
  echo "Cliente 03 en linea" >> $logfile
  echo "Copiando archivos del home a disco_backups" >> $logfile

  rsync -avz -e ssh --delete --exclude '.cache' cliente-03@192.168.20.3:/home /media/disco_backups/ >> $logfile

  echo "-----------------------------" >> $logfile
  echo "Backup completo - archivos en disco: " >> $logfile
  ls -la /media/disco_backups/home/cliente-03/ >> $logfile
else
  echo "Cliente 03 no esta en linea" >> $logfile
fi
