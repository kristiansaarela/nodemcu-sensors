require 'config'

function get_temp ()
	status, temp, humi, temp_dec, humi_dec = dht.read(dht_pin)

	if status == dht.OK then
		return temp, humi
	elseif status == dht.ERROR_CHECKSUM then
		return "DHT Checksum error"
	elseif status == dht.ERROR_TIMEOUT then
		return "DHT timed out"
	end
end

wifi.sta.config(wifi_ssid, wifi_pass)
wifi.sta.connect()

server = net.createServer(net.TCP, 30)

server:listen(80, function (client)
	tmr.alarm(0, 60000, tmr.ALARM_AUTO, function ()
		temp, humi = get_temp()

		if (temp ~= nil and humi ~= nil) then
			client:send(temp..","..humi)
		else
			client:send(temp)
		end
	end)
end)
