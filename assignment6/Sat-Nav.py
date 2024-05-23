#!/usr/bin/env python3

import re

from scapy.all import *

class Satnav(Packet):
    name = "Satnav"
    fields_desc = [ StrFixedLenField("P", "P", length=1),
                    StrFixedLenField("Four", "4", length=1),
                    XByteField("version", 0x01),
                    IntField("location", 0),
                    IntField("destination", 0),
                    XByteField("road_flag", 0x01),
                    IntField("prev_road", 0),
                    IntField("prev_time", 0)]

bind_layers(Ether, Satnav, type=0x1234)


def main():

    iface = "enx0c37965f8a0f"

    try:
        pkt = Ether(dst='00:04:00:00:00:00', type=0x1234) / Satnav()
        
        #put in satnav location = ..., etc.

        pkt = pkt/' '
        
        resp = srp1(pkt, iface=iface,timeout=5, verbose=False)
        if resp:
            satnav=resp[Satnav]
            if satnav:
                print(satnav.road_flag)
            else:
                print("cannot find satnav header in the packet")
        else:
            print("Didn't receive response")
    except Exception as error:
        print(error)


if __name__ == '__main__':
    main()


