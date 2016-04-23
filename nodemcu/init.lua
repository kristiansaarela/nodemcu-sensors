require 'config'

function get_temp ()
    status, temp, humi, temp_dec, humi_dec = dht.read(dht_pin)

    if status == dht.OK then
       return temp, humi
    elseif status == dht.ERROR_CHECKSUM then
        return "DHT Checksum error."
    elseif status == dht.ERROR_TIMEOUT then
        return "DHT timed out."
    end
end

wifi.sta.config(wifi_ssid, wifi_pass)
wifi.sta.connect()

sv = net.createServer(net.TCP, 30)

sv:listen(80, function (c)
    temp, humi = get_temp()

    if (temp ~= nil and humi ~= nil) then
        c:send("Temp: "..temp..", humi: "..humi)
    else
        c:send(temp)
    end
end)
