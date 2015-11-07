#	PUT32(IRQ_DISABLE_BASIC,1);	//TODO いるかも？

serial = Serial.new

timer = SystemTimer.new

gyro = Gyro.new() ## Gyro.new(Port::XX) ?

serial.puts("time,gyro")

## gyroの値からモーターを制御する
MESURE_COUNTS = 45 ## 定数

start_time = timer.now

cnt = 0
loop do
  mesure_sum = 0
  MESURE_COUNTS.times do
    mesure_sum += gyro.read(Gyro::Y)
  end

  omega_i = mesure_sum * 0.00875 / MESURE_COUNTS;

#  if omega_i.abs < 2
#    omega_i = 0
#  end

	cnt +=1
  now = ((timer.now - start_time) / 1000).floor
  if cnt == 10
  	cnt = 0
    serial.puts("#{now},#{omega_i}")
  end
end
