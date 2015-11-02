#	PUT32(IRQ_DISABLE_BASIC,1);	//TODO いるかも？

#	uart_init();
	serial = Serial.new

#	pwm_init();
	# in1,in2,enable,pwm0or1
	motorL = Motor.new(5,6,12,0)
	motorR = Motor.new(19,16,20,1)

#	timer_init();
	time = SystemTimer.new

#    spi_init();
    gyro = Gyro.new

#    "time, power,omegaI,thetaI,theta,omega,distance,vE5" という文字列をserialでかく
	serial.write("time, power,omegaI,thetaI,theta,omega,distance,vE5")

#    while(1){
#    	// gyroの値からモーターを制御する
#    	MESURE_COUNTS = 45; //定数

#        mesureSum = 0;
#        for(i = 0; i < MESURE_COUNTS; i++){
#        	gyro_val = gyro.read(Y)
#        	mesureSum = mesureSum + gyro_val;
#        }

#        omegaI = mesureSum * 0.00875 / MESURE_COUNTS;

#        if(abs(omegaI) < 2){
#        	omegaI = 0;
#        }
#        recOmegaI[0] = omegaI;
#        thetaI = thetaI + omegaI;
#        countS = 0;
#        for(i = 0; i < 10; i++){
#        	if(abs(recOmegaI[i]) < 4){
#        		countS++;
#        	}
#        }
#        if(countS > 9){
#        	thetaI = 0;
#        	vE5 = 0;
#        	xE5 = 0;
#        	sumPower = 0;
#        	sumSumP = 0;
#        }
#        for(i = 9; i > 0; i-- ){
#        	recOmegaI[i] = recOmegaI[i - 1];
#        }

#        long t = kAngle * thetaI / 100;
#        long o = kOmega * omegaI / 100;
#        long s = kSpeed * vE5 / 1000;
#        long d = kDistance * xE5 / 1000;
#        powerScale = t + o + s + d;
#//        power = max(min(95 * powerScale / 100, 255), -255);
#        long ltmp = 95 * powerScale / 100;
#        if(ltmp > 255){
#        	ltmp = 255;
#        }
#        if(ltmp < -255){
#        	ltmp = -255;
#        }
#        power = ltmp;
#        sumPower = sumPower + power;
#        sumSumP = sumSumP + sumPower;
#        vE5 = sumPower;
#        xE5 = sumSumP / 1000;

        #motorに渡す
#        if(power > 0){
#        	#正転
#        	motorL.drive(FOWARD, power)
##        	motorR.drive(FOWARD, power)
#        }else{
#        	#逆転
#        	motorL.drive(REVERSE, -1 * power)
#        	motorR.drive(REVERSE, -1 * power)
#        }

#//        unsigned long now = (unsigned long)((get_systime() -init_t) / 1000);
#        sprintf(buf, "%ld,%ld,%d,%ld,%ld,%ld%ld,%ld,%ld", now, power, omegaI, (thetaI/286), t, o, (d/200),vE5);
#        serial.write(buf)
#    }
