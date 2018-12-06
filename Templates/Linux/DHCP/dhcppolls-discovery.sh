#!/bin/bash
pools_all=`dhcpd-pools -c /etc/dhcp/dhcpd.conf -l /var/lib/dhcp/dhcpd.leases -L02|egrep -io "^[a-z]*(\-|\_)?([a-z]|[0-9])*"`
pools_qtd=`echo $pools_all|wc -w`
retorno=`echo -e "{\n\t\t"\"data\"":["`
for p in $pools_all
do
 if [ "$pools_qtd" -le "1" ]
 then
 retorno=$retorno`echo -e "\n\t\t{\"{#DHCPPOOL}\":\"$p\"}"`
 else
 retorno=$retorno`echo -e "\n\t\t{\"{#DHCPPOOL}\":\"$p\"},"`
 fi
 pools_qtd=$(($pools_qtd - 1))
done
retorno=$retorno`echo -e "]}"`
echo -e $retorno
