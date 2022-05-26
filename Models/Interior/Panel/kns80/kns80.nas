#<PropertyList><module>Aerostar-700</module><script><![CDATA[
####    King KNS-80 Integrated Navigation System   ####
####    Syd Adams    ####
####    Ron Jensen   ####
####
####	Must be included in the Set file to run the KNS80 radio 
####
#### Nav Modes  0 = VOR ; 1 = VOR/PAR ; 2 = RNAV/ENR ; 3 = RNAV/APR ;
####

var KNS80 = props.globals.getNode("/instrumentation/kns-80",1);
var NAV1 = props.globals.getNode("/instrumentation/nav/frequencies/selected-mhz",1);
var NAV1_RADIAL = props.globals.getNode("/instrumentation/nav/radials/selected-deg",1);
var KNS80_wpt_freq=[];
var KNS80_wpt_radial=[];
var KNS80_wpt_distance=[];

var KNS80_serviceable=KNS80.getNode("serviceable",1);
KNS80_serviceable.setBoolValue(1);

var KNS80_volume_adjust=KNS80.getNode("volume-adjust",1);
KNS80_volume_adjust.setDoubleValue(0);

var KNS80_data_adjust=KNS80.getNode("data-adjust",1);
KNS80_data_adjust.setDoubleValue(0);

var KNS80_volume=KNS80.getNode("volume",1);
KNS80_volume.setDoubleValue(0.5);

var KNS80_display=KNS80.getNode("display",1);
KNS80_display.setDoubleValue(0);

var KNS80_use=KNS80.getNode("use",1);
KNS80_use.setDoubleValue(0);

var KNS80_data_mode=KNS80.getNode("data-mode",1);
KNS80_data_mode.setDoubleValue(0);

var KNS80_nav_mode=KNS80.getNode("nav-mode",1);
KNS80_nav_mode.setDoubleValue(0);

var KNS80_dme_hold=KNS80.getNode("dme-hold",1);
KNS80_dme_hold.setBoolValue(0);

var KNS80_displayed_distance=KNS80.getNode("displayed-distance",1);
KNS80_displayed_distance.setDoubleValue(0);

var KNS80_displayed_frequency=KNS80.getNode("displayed-frequency",1);
KNS80_displayed_frequency.setDoubleValue(0.0);

var KNS80_displayed_radial=KNS80.getNode("displayed-radial",1);
KNS80_displayed_radial.setDoubleValue(0.0);

append(KNS80_wpt_freq,KNS80.getNode("wpt[0]/frequency",1));
append(KNS80_wpt_freq,KNS80.getNode("wpt[1]/frequency",1));
append(KNS80_wpt_freq,KNS80.getNode("wpt[2]/frequency",1));
append(KNS80_wpt_freq,KNS80.getNode("wpt[3]/frequency",1));

append(KNS80_wpt_radial,KNS80.getNode("wpt[0]/radial",1));
append(KNS80_wpt_radial,KNS80.getNode("wpt[1]/radial",1));
append(KNS80_wpt_radial,KNS80.getNode("wpt[2]/radial",1));
append(KNS80_wpt_radial,KNS80.getNode("wpt[3]/radial",1));

append(KNS80_wpt_distance,KNS80.getNode("wpt[0]/distance",1));
append(KNS80_wpt_distance,KNS80.getNode("wpt[1]/distance",1));
append(KNS80_wpt_distance,KNS80.getNode("wpt[2]/distance",1));
append(KNS80_wpt_distance,KNS80.getNode("wpt[3]/distance",1));

KNS80_wpt_freq[0].setDoubleValue(10950);
KNS80_wpt_radial[0].setDoubleValue(280);
KNS80_wpt_distance[0].setDoubleValue(0.0);
KNS80_wpt_freq[1].setDoubleValue(11570);
KNS80_wpt_radial[1].setDoubleValue(120);
KNS80_wpt_distance[1].setDoubleValue(7.2);
KNS80_wpt_freq[2].setDoubleValue(11570);
KNS80_wpt_radial[2].setDoubleValue(270);
KNS80_wpt_distance[2].setDoubleValue(5.8);
KNS80_wpt_freq[3].setDoubleValue(11000);
KNS80_wpt_radial[3].setDoubleValue(0);
KNS80_wpt_distance[3].setDoubleValue(0.0);

var DME_mhz=props.globals.getNode("instrumentation/dme/frequencies/selected-mhz",1);
var DME_src=props.globals.getNode("instrumentation/dme/frequencies/source",1);
var FDM_ON = 0;
var dsp_flash = props.globals.getNode("instrumentation/kns-80/flash", 1);
aircraft.light.new("instrumentation/kns-80/dsp-state", [0.5, 0.5],dsp_flash);

# Properties

var NAV1_ACTUAL = props.globals.getNode("/instrumentation/nav/radials/actual-deg",1);
var NAV1_TO_FLAG = props.globals.getNode("/instrumentation/nav[0]/to-flag",1);
var NAV1_FROM_FLAG = props.globals.getNode("/instrumentation/nav[0]/from-flag",1);
var NAV1_HEADING_NEEDLE_DEFLECTION = props.globals.getNode("/instrumentation/nav[0]/heading-needle-deflection",1);

var NAV1_IN_RANGE = props.globals.getNode("/instrumentation/nav[0]/in-range",1);
var DME1_IN_RANGE = props.globals.getNode("/instrumentation/dme[0]/in-range",1);

# outputs
var CDI_NEEDLE = props.globals.getNode("/instrumentation/gps/cdi-deflection",1);
var TO_FLAG    = props.globals.getNode("/instrumentation/gps/to-flag",1);
var FROM_FLAG  = props.globals.getNode("/instrumentation/gps/from-flag",1);


var RNAV = props.globals.getNode("/instrumentation/rnav",1);
# distance, radial from VOR Station
# rho, theta: distance and radial for phantom station
# range, bearing: distance and radial from phantom station

var PI=3.14159265;
var D2R=PI/180;
var R2D=180/PI;

var unnil = func(n) { n == nil ? 0 : n }


# 0.1 second cron
var sec01cron = func {
   updateRNAV();

   # schedule the next call
   settimer(sec01cron,0.1);
}


# general initialization
var init = func {
   # schedule the 1st call
   settimer(sec01cron,5);
}

var updateRNAV = func{
# check to see if we are in-range
    if( NAV1_IN_RANGE.getValue()==0) {
        return;
    }
    var dme_valid=DME1_IN_RANGE.getValue();
    if( dme_valid == 0) {
        return;
    }
    if( dme_valid == nil) {
        return;
    }

#### Nav Modes  0 = VOR ; 1 = VOR/PAR ; 2 = RNAV/ENR ; 3 = RNAV/APR ;
    var mode = KNS80_nav_mode.getValue();
    var use =KNS80_use.getValue();
    var distance=getprop("/instrumentation/dme/indicated-distance-nm");
    var selected_radial = NAV1_RADIAL.getValue();
    var radial = NAV1_ACTUAL.getValue();
    var rho = KNS80_wpt_distance[use].getValue();
    var theta = KNS80_wpt_radial[use].getValue();
#    var rho = KNS80.getNode("wpt[" ~ use ~ "]/distance").getValue();
#    var theta = KNS80.getNode("wpt[" ~ use ~ "]/radial").getValue();
    var fangle = 0;
    var needle_deflection = 0;
    var from_flag=1;
    var to_flag  =0;

    
    radial = unnil(radial);
    theta = unnil(theta);
    rho = unnil(rho);
    distance=unnil(distance);

    var x1 = distance * math.cos( radial*D2R );
    var y1 = distance * math.sin( radial*D2R );
    var x2 = rho * math.cos( theta*D2R );
    var y2 = rho * math.sin( theta*D2R );

    var range = math.sqrt( (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2) );
    var bearing = math.atan2 (( y1-y2), (x1-x2))*R2D;

    if(bearing < 0) bearing += 360;
    var abearing = bearing > 180 ? bearing - 180 : bearing + 180;

    if( mode == 0){
    #	print("KNS-80 VOR");
        needle_deflection = (NAV1_HEADING_NEEDLE_DEFLECTION.getValue());
        range = distance;
    #	return;
    }
    if ( mode == 1){
    #	print("KNS-80 VOR/PAR");
        fangle = math.abs(selected_radial - radial);
        needle_deflection = math.sin((selected_radial - radial) * D2R) * distance * 2;
    }
    if ( mode == 2){
    #	print("KNS-80 RNAV/ENR");
        fangle = math.abs(selected_radial - bearing);
        needle_deflection = math.sin((selected_radial - bearing) * D2R) * range * 2;
    } 
    if ( mode == 3){
    #	print("KNS-80 RNAV/APR");
        fangle = math.abs(selected_radial - bearing);
        needle_deflection = math.sin((selected_radial - bearing) * D2R) * range * 8;
    }

    if ( needle_deflection >  10) needle_deflection = 10;
    if ( needle_deflection < -10) needle_deflection =-10;
    if (fangle < 90 or fangle >270){
        from_flag=1;
        to_flag  =0;
    } else {
        from_flag=0;
        to_flag  =1;
    }

# valid=1;
    RNAV.getNode("heading-needle-deflection", 1).setDoubleValue(needle_deflection);
    CDI_NEEDLE.setDoubleValue(needle_deflection);
    TO_FLAG.setDoubleValue(to_flag);
    FROM_FLAG.setDoubleValue(from_flag);
    setprop("/instrumentation/rnav/indicated-distance-nm", range);
    setprop("/instrumentation/rnav/reciprocal-radial-deg", abearing);
    setprop("/instrumentation/rnav/actual-deg", bearing);
##debugging
##setprop("/instrumentation/rnav/debug-angle-deg", angle*R2D);
##setprop("/instrumentation/rnav/debug-anglef-deg", fangle);
##setprop("/instrumentation/rnav/debug-theta-deg",theta);
##setprop("/instrumentation/rnav/debug-rho", rho);


}

setlistener("/sim/signals/fdm-initialized", func {
    KNS80_displayed_frequency.setDoubleValue(10955);
    KNS80_displayed_radial.setDoubleValue(NAV1_RADIAL.getValue());
    KNS80_wpt_radial[0].setDoubleValue(NAV1_RADIAL.getValue());
    tmp=props.globals.getNode("/instrumentation/nav/ident");
    tmp.setBoolValue(0);
    init();
    print("KNS-80 Nav System ... OK");
    });

setlistener(KNS80_volume_adjust, func(voladj){
    var amnt = voladj.getValue();
    if(amnt == nil){return;}
    amnt*=0.05;
    voladj.setDoubleValue(0);
    var vol = KNS80_volume.getValue();
    vol+= amnt;
    if(vol > 1.0)vol = 1.0;
    if(vol < 0.0){
        vol = 0.0;
        KNS80_serviceable.setBoolValue(0);
    }
    if(vol > 0.0)KNS80_serviceable.setBoolValue(1);
    KNS80_volume.setDoubleValue(vol);
    KNS80_volume_adjust.setDoubleValue(0);
    },1,0);

setlistener(KNS80_data_adjust, func(dtadj){
    var dmode = KNS80_data_mode.getValue();
    var num = dtadj.getValue();
    dtadj.setDoubleValue(0);
    if(dmode == 0){
        if(num == -1 or num ==1){num = num *5;}else{num = num *10;}
        var newfreq = KNS80_displayed_frequency.getValue();
        newfreq += num;
        if(newfreq > 11895){newfreq -= 1100;}
        if(newfreq < 10800){newfreq += 1100;}
        KNS80_displayed_frequency.setDoubleValue(newfreq);
    }elsif(dmode == 1){
        var newrad = KNS80_displayed_radial.getValue();
        newrad += num;
        if(newrad > 359){newrad -= 360;}
        if(newrad < 0){newrad += 360;}
        KNS80_displayed_radial.setDoubleValue(newrad);
    }elsif(dmode == 2){
        var newdist = KNS80_displayed_distance.getValue();
        if(num == -1 or num ==1 ){num = num *0.1;}
        newdist += num;
        if(newdist > 99){newdist -= 100;}
        if(newdist < 0){newdist += 100;}
        KNS80_displayed_distance.setDoubleValue(newdist);
    }
},1,0);

setlistener(KNS80_displayed_frequency, func(dspfrq){
    var freq = dspfrq.getValue();
    var num = KNS80_display.getValue();
    var use = KNS80_use.getValue();
    KNS80_wpt_freq[num].setDoubleValue(freq);
    NAV1.setDoubleValue(KNS80_wpt_freq[num].getValue() * 0.01);
    },1,0);

setlistener(KNS80_displayed_radial, func(rdl){
    var rad = rdl.getValue();
    var num = KNS80_display.getValue();
    var radial = KNS80_use.getValue();
    KNS80_wpt_radial[num].setDoubleValue(rad);
    },1,0);

setlistener(KNS80_displayed_distance, func(dst){
    var dis = dst.getValue();
    var num = KNS80_display.getValue();
    KNS80_wpt_distance[num].setDoubleValue(dis);
},1,0);

setlistener(KNS80_serviceable, func(srv){
    setprop("/instrumentation/nav/serviceable",srv.getValue());
    setprop("/instrumentation/dme/serviceable",srv.getValue());
    },1,0);

setlistener(KNS80_volume, func(vol){
    setprop("/instrumentation/nav/volume",vol.getValue());
    setprop("/instrumentation/dme/volume",vol.getValue());
    },1,0);

setlistener(KNS80_use, func(frq){
    var freq = frq.getValue();
    KNS80.getNode("flash").setDoubleValue(0);
    KNS80_data_mode.setDoubleValue(0);
    NAV1.setDoubleValue(KNS80_wpt_freq[freq].getValue()* 0.01);
    },1,0);

setlistener(KNS80_display, func(dsp){
    var freq = dsp.getValue();
    if(freq == nil)return;
    var test = KNS80_use.getValue();
    var wpt = KNS80_wpt_freq[freq].getValue();
    KNS80_displayed_frequency.setDoubleValue(wpt);
    KNS80_displayed_distance.setDoubleValue(KNS80_wpt_distance[freq].getValue());
    KNS80_displayed_radial.setDoubleValue(KNS80_wpt_radial[freq].getValue());
    KNS80_data_mode.setDoubleValue(0);
    if(test != freq){
        KNS80.getNode("flash").setDoubleValue(1);
        }else{
        KNS80.getNode("flash").setDoubleValue(0);
        }
    },1,0);

setlistener(KNS80_dme_hold, func(hld){
    if(hld.getBoolValue()){
        DME_mhz.setDoubleValue(NAV1.getValue());
        DME_src.setValue("/instrumentation/dme/frequencies/selected-mhz");
    }else{
        DME_mhz.setDoubleValue(0);
        DME_src.setValue("/instrumentation/nav[0]/frequencies/selected-mhz");
        }
    },1,0);

#  ]]></script></PropertyList>
