#include <core.p4>
#include <v1model.p4>

/*
 * Define the headers the program will recognize
 */

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

const bit<16> SAT_NAV_ETYPE = 0x1234; // Ethernet type
const bit<8>  SAT_NAV_P     = 0x50;   // 'P'
const bit<8>  SAT_NAV_4     = 0x34;   // '4'
const bit<8>  SAT_NAV_VER   = 0x01;   // ver0.1
const bit<8>  NO_FLAG       = 0x00;   // No road finished
const bit<8>  FLAG          = 0x11;   // Road finished

header p4satnav_t {
    bit<8> p;
    bit<8> four;
    bit<8> ver;
    bit<8> location;
    bit<8> destination;
    bit<8> road_flag
    bit<16> prev_road;
    bit<8> prev_time;
}

struct headers {
    ethernet_t   ethernet;
    satnav_t     satnav;
}

struct metadata {

}

/*************************************************************************
 ***********************  P A R S E R  ***********************************
 *************************************************************************/
 
 //parse and check packet is of correct format
 
parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {
                
    state start {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            SAT_NAV_ETYPE : check_satnav;
            default       : accept;
        }
    }

    state check_satnav {

        transition select(packet.lookahead<satnav_t>().p,
        packet.lookahead<satnav_t>().four, packet.lookahead<satnav_t>().ver) {
            (SAT_NAV_P, SAT_NAV_4, SAT_NAV_VER) : parse_satnav;
            default                             : accept;
        }
    }

    state parse_satnav {
        packet.extract(hdr.satnav);
        transition accept;
    }
}

/*************************************************************************
 ************   C H E C K S U M    V E R I F I C A T I O N   *************
 *************************************************************************/
control MyVerifyChecksum(inout headers hdr,
                         inout metadata meta) {
    apply { }
}

/*************************************************************************
 **************  I N G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/
control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    
    action send_back() {
         
         hdr.p4calc.road_flag = 0x12;
         
         bit<48> tmp = hdr.ethernet.srcAddr;
         hdr.ethernet.dstAddr = hdr.ethernet.srcAddr;
         hdr.ethernet.srcAddr = tmp;
         
         standard_metadata.ingress_port = standard_metadata.egress_port;
    }
    
    action return_shortest_route() {
        sendback();
    }
    
    action matrix_update() {
        return_shortest_route();
    }

    table calculate {
        key = {
            hdr.satnav.road_flag : exact;
        }
        actions = {
	    tables_update;
	    shortest_route;
        }
        const default_action = operation_drop();
        const entries = {
            FLAG    : matrix_update();
            NO_FLAG : return_shortest_route();
        }
    }

    apply {
        if (hdr.p4calc.isValid()) {
            calculate.apply();
        } else {
            operation_drop();
        }
    }
}

/*************************************************************************
 ****************  E G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/
control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply { }
}

/*************************************************************************
 *************   C H E C K S U M    C O M P U T A T I O N   **************
 *************************************************************************/

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
    apply { }
}

/*************************************************************************
 ***********************  D E P A R S E R  *******************************
 *************************************************************************/
control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.p4calc);
    }
}

/*************************************************************************
 ***********************  S W I T T C H **********************************
 *************************************************************************/

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;
