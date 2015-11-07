# in1, in2, enable, pwm0or1
motor_left = Motor.new(5,6,12,0)
motor_right = Motor.new(16,20,19,1)

motor_right.drive(100)
motor_left.drive(100) ## powerがマイナスなら逆転
RSRobot.delay(0x1000000)
motor_left.drive(200)
motor_right.drive(200)
RSRobot.delay(0x1000000)
motor_left.stop
motor_right.stop
