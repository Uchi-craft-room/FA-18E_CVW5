setprop("instrumentation/steer-mode",0);


var dme_step = func(stp){
    var swtch= getprop("instrumentation/steer-mode");
    swtch += stp;
    if(swtch >3)swtch=3;
    if(swtch ==2)swtch=2;
    if(swtch ==1)swtch=1;
    if(swtch <0)swtch=0;
    setprop("instrumentation/steer-mode",swtch);

    if(swtch==0){setprop("instrumentation/dme/frequencies/source","instrumentation/tacan/frequencies/selected-mhz")};
    if(swtch==1){setprop("instrumentation/dme/frequencies/source","instrumentation/nav[0]/frequencies/selected-mhz")};
    if(swtch==2){setprop("instrumentation/dme/frequencies/source","instrumentation/tacan/frequencies/selected-mhz")};
    if(swtch==3){setprop("instrumentation/dme/frequencies/source","instrumentation/nav[0]/frequencies/selected-mhz")};
}

