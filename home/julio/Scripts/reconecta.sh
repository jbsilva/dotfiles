#!/bin/bash

host1=google.com
host2=wikipedia.org
curr_date=`date +"%Y_%m_%d-%H:%M"`
REDE=$2

echo "Rede = $REDE"

UP=`((ping -w5 -c3 $host1 || ping -w5 -c3 $host2) > /dev/null 2>&1) && echo 1 || echo 0`

if [ $UP -eq 1 ]
then
    echo "$curr_date --> Ja estava conectado" >> /home/julio/Scripts/reconecta.log
else
    TENTATIVA=0
    CONECTOU=1
    while [ $CONECTOU -ne 0 ] && [ $TENTATIVA -lt $1 ]
    do
        #ip link set eth0 down && ip link set eth0 up && ip route del default
        netcfg reconnect $REDE

        CONECTOU=$?
        TENTATIVA=`expr $TENTATIVA + 1`

        if [ $CONECTOU -eq 0 ]
        then
            echo "$curr_date --> $CONECTOU --> TUDO OK" >> /home/julio/Scripts/reconecta.log
        else
            echo "$curr_date --> $CONECTOU --> ERRO. Tentativa $TENTATIVA" >> /home/julio/Scripts/reconecta.log
            sleep 5
        fi
    done
fi
