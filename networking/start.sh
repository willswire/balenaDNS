#!/bin/bash

# Check to see if the DNS_1 entry has been set
if [[ -z "${DNS_1}" ]]; then
      while :; do
            echo -e "\e[33mThe \$DNS_1 variable is empty and needs to be set\e[0m"
            sleep 30
      done
fi

# Check to see if the DNS_2 entry has been set
if [[ -z "${DNS_2}" ]]; then
      while :; do
            echo -e "\e[33mThe \$DNS_2 variable is empty and needs to be set\e[0m"
            sleep 30
      done
fi

echo -e "Setting DNS servers to:\n$DNS_1\n$DNS_2"

## Break up the IP addresses into octet sets
delimiter=.

ip_one=$DNS_1$delimiter
ip_one_array=();
while [[ $ip_one ]]; do
    ip_one_array+=( "${ip_one%%"$delimiter"*}" );
    ip_one=${ip_one#*"$delimiter"};
done;

ip_two=$DNS_2$delimiter
ip_two_array=();
while [[ $ip_two ]]; do
    ip_two_array+=( "${ip_two%%"$delimiter"*}" );
    ip_two=${ip_two#*"$delimiter"};
done;

## Convert the IP addresses to unsigned integers
(( ip_one=(ip_one_array[0] * 16777216) + (ip_one_array[1] * 65536) + (ip_one_array[2] * 256) + (ip_one_array[3]) ));
(( ip_two=(ip_two_array[0] * 16777216) + (ip_two_array[1] * 65536) + (ip_two_array[2] * 256) + (ip_two_array[3]) ));

## Tell the HostOS to set the DNS servers accordingly
DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket \
  dbus-send \
  --system \
  --reply-timeout=2000 \
  --print-reply=literal \
  --type=method_call \
  --dest=uk.org.thekelleys.dnsmasq \
  /uk/org/thekelleys/dnsmasq  \
  uk.org.thekelleys.SetServers \
  uint32:$ip_one uint32:$ip_two

echo "DNS servers set"
