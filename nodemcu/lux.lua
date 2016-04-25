LED_PIN = 4
SDA_PIN = 6 -- sda pin, GPIO12
SCL_PIN = 5 -- scl pin, GPIO14

gpio.mode(LED_PIN, gpio.OUTPUT)

tmr.alarm(0, 1000, tmr.ALARM_AUTO, function ()
    id = 0

    i2c.setup(id, SDA_PIN, SCL_PIN, i2c.SLOW)
    i2c.start(id)
    i2c.address(id, 0x23, i2c.TRANSMITTER)
    i2c.write(id, 0x10)
    i2c.stop(id)
    i2c.start(id)
    i2c.address(id, 0x23, i2c.RECEIVER)
    tmr.delay(200000)

    raw = i2c.read(id, 2)

    i2c.stop(id)

    lux_raw = raw:byte(1) * 256 + raw:byte(2)
    lux = (lux_raw * 1000 / 12)

    print((lux / 100).." or "..(lux % 100).." lx")

    if (lux / 100) < 12.0 then
        gpio.write(LED_PIN, gpio.LOW)
    else
        gpio.write(LED_PIN, gpio.HIGH)
    end
end)
