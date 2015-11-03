#	PUT32(IRQ_DISABLE_BASIC,1);	//TODO いるかも？

k_angle = 80
k_omega = 800
k_speed = 55
k_distance = 20

serial = Serial.new

# in1, in2, enable, pwm0or1
motor_left = Motor.new(5,6,12,0)
motor_right = Motor.new(19,16,20,1)

timer = SystemTimer.new

gyro = Gyro.new() ## Gyro.new(Port::XX) ?

serial.puts("time,power,omegaI,thetaI,theta,omega,distance,vE5")

## gyroの値からモーターを制御する
MESURE_COUNTS = 45 ## 定数

rec_omega_i = [0]*10
theta_i = 0
v_e5 = 0
x_e5 = 0
sum_power = 0
sum_sum_power = 0

start_time = timer.now

loop do
  mesure_sum = 0
  MESURE_COUNTS.times do
    mesure_sum += gyro.read(Gyro::Y)
  end

  omega_i = mesure_sum * 0.00875 / MESURE_COUNTS;

  if omega_i.abs < 2
    omega_i = 0
  end
  rec_omega_i[0] = omega_i
  theta_i += omega_i

  count_s = 0
  10.times do |i|
    if rec_omega_i[i].abs < 4
      count_s+=1
    end
  end

  if count_s > 9
    theta_i = 0
    v_e5 = 0
    x_e5 = 0
    sum_power = 0;
    sum_sum_power = 0;
  end
  9.step(1, -1) do |i|
    rec_omega_i[i] = rec_omega_i[i - 1]
  end

  t = k_angle * theta_i / 100.0
  o = k_omega * omega_i / 100.0
  s = k_speed * v_e5 / 1000.0
  d = k_distance * x_e5 / 1000.0
  power_scale = t + o + s + d
  ##  power = max(min(95 * powerScale / 100, 255), -255)
  ltmp = 95 * power_scale / 100.0
  if ltmp > 255
    ltmp = 255
  end
  if ltmp < -255
    ltmp = -255
  end
  power = ltmp
  sum_power += power
  sum_sum_power += sum_power
  v_e5 = sum_power
  x_e5 = sum_sum_power / 1000.0

  # motorに渡す
  motor_left.drive(power) ## powerがマイナスなら逆転
  motor_right.drive(power)

  now = ((timer.now - start_time) / 1000).floor
  serial.puts("#{now},#{power},#{omega_i},#{theta_i/286},#{t},#{o},#{d/200},#{v_e5}")
end
