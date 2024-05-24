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

register<bit<16>>(65535)adjacency_matrix;

header satnav_t {
    bit<8>  p;
    bit<8>  four;
    bit<8>  ver;
    bit<16>  location;
    bit<16>  destination;
    bit<8>  road_flag;
    bit<32> prev_road;
    bit<16>  prev_time;
    bit<16>  point1;
    bit<16>  point2;
}

struct headers {
    ethernet_t      ethernet;
    satnav_t        satnav;
}

struct metadata_t {
}

/*************************************************************************
 ***********************  P A R S E R  ***********************************
 *************************************************************************/
 
 //parse and check packet is of correct format
 
parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata_t meta,
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
                         inout metadata_t meta) {
    apply { }
}

/*************************************************************************
 **************  I N G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/
control MyIngress(inout headers hdr,
                  inout metadata_t meta,
                  inout standard_metadata_t standard_metadata) {
    
    action send_back() {
             
        adjacency_matrix.read(hdr.satnav.destination, hdr.satnav.prev_road);
        bit<48> tmp = hdr.ethernet.srcAddr;
        hdr.ethernet.dstAddr = hdr.ethernet.srcAddr;
        hdr.ethernet.srcAddr = tmp;
         
        standard_metadata.ingress_port = standard_metadata.egress_port;
    }

    action operation_drop() {
        mark_to_drop(standard_metadata);
    }
    
    action update_matrix() {
        adjacency_matrix.write(hdr.satnav.prev_road, hdr.satnav.destination);
        send_back();
    }

    table navigation {
        key = {
            hdr.satnav.road_flag : exact;
        }
        actions = {
	    update_matrix;
	    send_back;
            operation_drop;
        }
        const default_action = send_back();
        const entries = {
            FLAG : update_matrix;
            NO_FLAG : send_back;
        }
    }

    apply {
        if (hdr.satnav.isValid()) {
            navigation.apply();
        }
        else {
            operation_drop();
        }
    }
}

/*************************************************************************
 ****************  E G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/
control MyEgress(inout headers hdr,
                 inout metadata_t meta,
                 inout standard_metadata_t standard_metadata) {
    apply { }
}

/*************************************************************************
 *************   C H E C K S U M    C O M P U T A T I O N   **************
 *************************************************************************/

control MyComputeChecksum(inout headers hdr, inout metadata_t meta) {
    apply { }
}

/*************************************************************************
 ***********************  D E P A R S E R  *******************************
 *************************************************************************/
control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.satnav);
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
