#!/usr/bin/with-contenv bashio
CorF=$(cat options.json |jq -r '.CorF')
until false; do 
  read cpuRawTemp</sys/class/thermal/thermal_zone0/temp 
  read gpuRawTemp</sys/class/thermal/thermal_zone1/temp 
  
  cpuTemp=`awk -v n=$cpuRawTemp 'BEGIN {printf "%.2f\n", (n/1000)}'`
  gpuTemp=`awk -v n=$gpuRawTemp 'BEGIN {printf "%.2f\n", (n/1000)}'`
  
  unit="C"
  if [ $CorF == "F" ]; then
    cpuTemp=$(( ( $cpuTemp *  9/5 ) + 32 ));
    gpuTemp=$(( ( $gpuTemp *  9/5 ) + 32 ));
    unit="F"
  fi
  echo "Current Temperature $cpuTemp °$unit\n"
  curl -s -X POST -H "Content-Type: application/json"  -H "Authorization: Bearer $HASSIO_TOKEN" -d '{"state": "'$cpuTemp'","entity_id":"cpu.temp", "attributes":  {"unit_of_measurement": "°'$unit'", "icon": "mdi:clock-start", "friendly_name": "CPU Temp"}}' http://hassio/homeassistant/api/states/sensor.cpu_temp 2>/dev/null
  curl -s -X POST -H "Content-Type: application/json"  -H "Authorization: Bearer $HASSIO_TOKEN" -d '{"state": "'$gpuTemp'","entity_id":"gpu.temp", "attributes":  {"unit_of_measurement": "°'$unit'", "icon": "mdi:clock-start", "friendly_name": "GPU Temp"}}' http://hassio/homeassistant/api/states/sensor.gpu_temp 2>/dev/null
  
  sleep 30;
done
``