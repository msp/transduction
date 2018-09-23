import argparse
import math
import time
import unicornhathd

from pythonosc import dispatcher
from pythonosc import osc_server

def tidal_handler(*args):
    
    try:
        unicornhathd.brightness(1)
        
        red = 0
        blue = 0
        green = 0
        crush = False 
    
        for num, arg in enumerate(args, start=1):
            #print("{0}: {1}".format(num, arg))
            
            if arg == "red":
                red = int(args[num])
            elif arg == "green":
                green = int(args[num])
            elif arg == "blue":
                blue = int(args[num])
            elif arg == "crush":
                crush = True              

        print("r: {0} g: {1} b: {2} crush: {3}".format(red, green, blue, crush))

        if crush == True:
            red = 255
            blue = 255
            green = 255

        unicornhathd.set_all(red, green, blue)
        unicornhathd.show()
        
        time.sleep(0.05)
        unicornhathd.off()

    except KeyboardInterrupt:
        unicornhathd.off()
        
def print_volume_handler(unused_addr, args, volume):
  print("[{0}] ~ {1}".format(args[0], volume))

def print_compute_handler(unused_addr, args, volume):
  try:
    print("[{0}] ~ {1}".format(args[0], args[1](volume)))
  except ValueError: pass

if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  parser.add_argument("--ip",
      default="0.0.0.0", help="The ip to listen on")
  parser.add_argument("--port",
      type=int, default=5005, help="The port to listen on")
  args = parser.parse_args()

  dispatcher = dispatcher.Dispatcher()
  #dispatcher.map("/debug", print)
  dispatcher.map("/volume", print_volume_handler, "Volume")
  dispatcher.map("/play2", tidal_handler)
  
  dispatcher.map("/logvolume", print_compute_handler, "Log volume", math.log)

  server = osc_server.ThreadingOSCUDPServer(
      (args.ip, args.port), dispatcher)
  print("Serving on {}".format(server.server_address))
  server.serve_forever()
