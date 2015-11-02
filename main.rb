#	PUT32(IRQ_DISABLE_BASIC,1);	//TODO いるかも？

	uart_init();

	pwm_init();

	timer_init();	//TODO たぶんいらないはず

    spi_init();

    "time, power,omegaI,thetaI,theta,omega,distance,vE5" という文字列をserialでかく

    while(1){
    	// gyroの値からモーターを制御する
        int i;
    	char buf[128];
    	int mesureN = 45; //org

        R = 0;
//        unsigned long nows[mesureN];
        for(i = 0; i < mesureN; i++){
        	// Y上位受信
        	h = spi_read(0x2B);
        	// Y下位受信
        	l = spi_read(0x2A);
            y = h << 8 | l;
            if (y>0x8000) {
            	y-=0x10000;
            }
        	ry = -1 * y;
        	R = R + ry;
        }

        omegaI = R * 0.00875 / mesureN;

        if(abs(omegaI) < 2){
        	omegaI = 0;
        }
        recOmegaI[0] = omegaI;
        thetaI = thetaI + omegaI;
        countS = 0;
        for(i = 0; i < 10; i++){
        	if(abs(recOmegaI[i]) < 4){
        		countS++;
        	}
        }
        if(countS > 9){
        	thetaI = 0;
        	vE5 = 0;
        	xE5 = 0;
        	sumPower = 0;
        	sumSumP = 0;
        }
        for(i = 9; i > 0; i-- ){
        	recOmegaI[i] = recOmegaI[i - 1];
        }

//        powerScale = (kAngle * thetaI / 100) + (kOmega * omegaI / 100)
//        		   + ( kSpeed * vE5 / 1000 ) + ( kDistance * xE5 / 1000 );
        long t = kAngle * thetaI / 100;
        long o = kOmega * omegaI / 100;
        long s = kSpeed * vE5 / 1000;
        long d = kDistance * xE5 / 1000;
        powerScale = t + o + s + d;
//        power = max(min(95 * powerScale / 100, 255), -255);
        long ltmp = 95 * powerScale / 100;
        if(ltmp > 255){
        	ltmp = 255;
        }
        if(ltmp < -255){
        	ltmp = -255;
        }
        power = ltmp;
        sumPower = sumPower + power;
        sumSumP = sumSumP + sumPower;
        vE5 = sumPower; //76a
        xE5 = sumSumP / 1000; //77a

        //motorに渡す
        if(power > 0){
        	//正転
			setServo(L_MOTOR, FOWARD, power);
			setServo(R_MOTOR, FOWARD, power);
        }else{
        	//逆転
			setServo(L_MOTOR, REVERSE, -1 * power);
			setServo(R_MOTOR, REVERSE, -1 * power);
        }

//        unsigned long now = (unsigned long)((get_systime() -init_t) / 1000);
        sprintf(buf, "%ld,%ld,%d,%ld,%ld,%ld%ld,%ld,%ld", now, power, omegaI, (thetaI/286), t, o, (d/200),vE5);
        serialでかく
    }
//------------ ruby
