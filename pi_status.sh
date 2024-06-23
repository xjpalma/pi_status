#!/usr/bin/env bash

CPU(){
  volts=$(vcgencmd measure_volts core | cut -d'=' -f 2)
  gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
  freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq | awk '{printf("%.0f\n"), $1/1000}')
  freq=$((freq))
  cpuname=$(lscpu | awk '/Model name:/{print $3}')

  echo -e "CPU: $cpuname"
  echo -e "System voltage: $volts"
  echo -e "CPU Governor: $gov"
  echo -e "Current speed: $freq MHz"
}

MEMORY(){
  usedRAM=$(free | awk '/Mem/{printf("%.2f\n"), $3/1024}')
  freeRAM=$(free | awk '/Mem/{printf("%.2f\n"), $4/1024}')
  cacheRAM=$(free | awk '/Mem/{printf("%.2f\n"), $6/1024}')

  # Print free & used RAM
  echo -e "Free RAM: $freeRAM MB"
  echo -e "Used RAM: $usedRAM MB"
  echo -e "Cache RAM: $cacheRAM MB"

  #vcgencmd get_mem arm
  #vcgencmd get_mem gpu
}

UPTIME(){
  up=$(uptime -p)
  since=$(uptime -s)
  # print system uptime
  echo -e "$up ; Up since $since"
}

TEMP(){
  max_temp=60
  temp=$(vcgencmd measure_temp | cut -d'=' -f 2 | cut -d"'" -f 1)

  echo -e "CPU temp: $temp °C"

  if (( $(echo "$temp > $max_temp" |bc -l) )); then
    echo -e "CPU temp=$temp°C"
  fi

}

IP(){
  out_ip=$(curl -s https://icanhazip.com)
  #out_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
  in_ip=$(hostname -I)

  echo -e "Private IP: $in_ip"
  echo -e " Public IP: $out_ip"
}

STATUS(){
  date -R
  UPTIME
  echo ""
  CPU
  echo ""
  MEMORY
  echo ""
  TEMP
  echo ""
  IP
}

HELP(){
  echo "Usage: $(basename $0) [-c] [-m] [-t] [-i] [-s]"
  echo "              -c: CPU"
  echo "              -m: Memory RAM"
  echo "              -t: Temperaturue"
  echo "              -i: IP"
  echo "              -s: Summary"
}


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [ -z "$1" ]; then
    HELP
fi
while getopts 'mctsih' opt; do
  case "$opt" in
    m)
      MEMORY
      ;;
    c)
      CPU
      ;;
    t)
      TEMP
      ;;
    i)
      IP
      ;;
    s)
      STATUS
      ;;
    h)
      echo "Usage: $(basename $0) [-c] [-m] [-t] [-i] [-s]"
      exit 1
      ;;
  esac
done

exit 0
