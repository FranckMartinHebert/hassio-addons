#!/usr/bin/with-contenv bashio
CorF=$(cat options.json |jq -r '.CorF')
until false; do 
  read cpuRawTemp</sys/class/thermal/thermal_zone0/temp 
  read cpuRawTemp1</sys/class/thermal/thermal_zone1/temp 
  cpuTemp=$(( $cpuRawTemp / 1000 ))
  cpuTemp1=$(( $cpuRawTemp1 / 1000 ))
  unit="C"
  if [ $CorF == "F" ]; then
    cpuTemp=$(( ( $cpuTemp *  9/5 ) + 32 ));
    cpuTemp1=$(( ( $cpuTemp1 *  9/5 ) + 32 ));
    unit="F"
  fi
  echo "Current Temperature $cpuTemp °$unit and $cpuTemp1 °$unit\n"
  curl -s -X POST -H "Content-Type: application/json"  -H "Authorization: Bearer $HASSIO_TOKEN" -d '{"state": "'$cpuTemp'", "entity_id":"odroid.temp0", "attributes":  {"unit_of_measurement": "°'$unit'", "icon": "mdi:clock-start", "friendly_name": "CPU Temp 0"}}' http://hassio/homeassistant/api/states/sensor.cpu_temp 2>/dev/null
  #curl -s -X POST -H "Content-Type: application/json"  -H "Authorization: Bearer $HASSIO_TOKEN" -d '{"state": "'$cpuTemp1'","entity_id":"odroid.temp1", "attributes":  {"unit_of_measurement": "°'$unit'", "icon": "mdi:clock-start", "friendly_name": "CPU Temp 1"}}' http://hassio/homeassistant/api/states/sensor.cpu_temp 2>/dev/null
  
  sleep 30;
done