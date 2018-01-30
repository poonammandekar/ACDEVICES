--Setting up to NodeMCU Wi-Fi module in Station + Access Poing Mode
wifi.setmode(wifi.STATIONAP)

--Configuring WiFi Access Point
cfg={}
 cfg.ssid="Switch"
 cfg.pwd="1234567@123"
 wifi.ap.config(cfg)

--Configuring WiFi Station
wifi.sta.config("smartswitch","1234567@123")

--Configure the Pins for Switching Relay
print(wifi.sta.getip())
_sw1 = 5
_sw2 = 6
_sw3 = 7
_sw4 = 2


gpio.mode(_sw1, gpio.OUTPUT)
gpio.mode(_sw2, gpio.OUTPUT)
gpio.mode(_sw3, gpio.OUTPUT)
gpio.mode(_sw4, gpio.OUTPUT)

--Setting all selected pins to High to switch relay to low
gpio.write(_sw1, gpio.HIGH);
gpio.write(_sw2, gpio.HIGH);
gpio.write(_sw3, gpio.HIGH);
gpio.write(_sw4, gpio.HIGH);

--Creating a TCP server to handle Request
srv=net.createServer(net.TCP)
        --Configuring the socket to listen on port number 80
        srv:listen(80,function(conn)
            --Handle for receiving client connection request
            conn:on("receive", function(client,request)
                local buf = "";
                --Filtering for HTTP request
                local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
                if(method == nil)then
                    _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
                end
                local _GET = {}
                if (vars ~= nil)then
                    --Retrieving the Value to vars variable for performing the On and Off Action
                    for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                        _GET[k] = v
                    end
                end
                --Storing the HTML Page data in buf variable
                buf = buf.."<style>.button {width:25%;background-color: #4CAF50;border: none;color: white;padding: 15px 32px; text-align: center; text-decoration: none;display: inline-block;font-size: 16px;}</style>";
                buf = buf.."<style>.button1 {background-color: #f44336;}</style>";
                buf = buf.."<div style=\"text-align:center;\"><h1> Smart Switch Web Server</h1></div><hr>";
                buf = buf.."<div style=\"text-align:center;\"><h2>Switch 1 </h2><a href=\"?pin=ON1\"><button class=\"button\">ON</button></a>&nbsp;<a href=\"?pin=OFF1\"><button class=\"button button1\">OFF</button></a></div>";
                buf = buf.."<div style=\"text-align:center;\"><h2>Switch 2 </h2><a href=\"?pin=ON2\"><button class=\"button\">ON</button></a>&nbsp;<a href=\"?pin=OFF2\"><button class=\"button button1\">OFF</button></a></div>";
                buf = buf.."<div style=\"text-align:center;\"><h2>Switch 3 </h2><a href=\"?pin=ON3\"><button class=\"button\">ON</button></a>&nbsp;<a href=\"?pin=OFF3\"><button class=\"button button1\">OFF</button></a></div>";
                buf = buf.."<div style=\"text-align:center;\"><h2>Switch 4 </h2><a href=\"?pin=ON4\"><button class=\"button\">ON</button></a>&nbsp;<a href=\"?pin=OFF4\"><button class=\"button button1\">OFF</button></a></div>";
                local _on,_off = "",""
               
                
                if(_GET.pin == "ON1")then
                      gpio.write(_sw1, gpio.LOW);
                elseif(_GET.pin == "OFF1")then
                      gpio.write(_sw1, gpio.HIGH);
                elseif(_GET.pin == "ON2")then
                      gpio.write(_sw2, gpio.LOW);
                elseif(_GET.pin == "OFF2")then
                      gpio.write(_sw2, gpio.HIGH);
                elseif(_GET.pin == "ON3")then
                      gpio.write(_sw3, gpio.LOW);
                elseif(_GET.pin == "OFF3")then
                      gpio.write(_sw3, gpio.HIGH);
                elseif(_GET.pin == "ON4")then
                      gpio.write(_sw4, gpio.LOW);
                elseif(_GET.pin == "OFF4")then
                      gpio.write(_sw4, gpio.HIGH);
                end

                --Once the triggering action is performed, send the HTML page back to the client and listen to further request
                client:send(buf);
                --Closing the server connection with the Client
                client:close();
                --Disallocate all the memory required the server data and variables.
                collectgarbage();
            end)
end)

