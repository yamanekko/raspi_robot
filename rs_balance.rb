#	PUT32(IRQ_DISABLE_BASIC,1);	//TODO いるかも？

##
# additional method for Gyro class
#
class Gyro
  def measure(axis, n)
    sum = 0
    n.times do
      sum += read(axis)
    end
    sum * 0.00875 / n
  end
end

##
# Balancer class
#
class Balancer
  def initialize(angle, omega, speed, distance)
    @k_angle = angle
    @k_omega = omega
    @k_speed = speed
    @k_distance = distance

	@counter = 0

    reset
  end

  ##
  # reset balancer
  #
  def reset
    @rec_omega_i = [0]*10
    @theta_i = 0
    @v_e5 = 0
    @x_e5 = 0
    @sum_power = 0
    @sum_sum_power = 0
  end

  def calculate(omega_i)
    if omega_i.abs < 2
      omega_i = 0
    end
    @theta_i += omega_i

    @rec_omega_i.unshift(omega_i)
    @rec_omega_i.pop

    if @rec_omega_i.all?{|x| x.abs < 4 }
      reset
    end

    t = @k_angle * @theta_i / 100.0
    o = @k_omega * omega_i / 100.0
    s = @k_speed * @v_e5 / 1000.0
    d = @k_distance * @x_e5 / 1000.0
    power_scale = t + o + s + d

    power = 0.95 * power_scale
    if power > 255
      power = 255
    elsif power < -255
      power = -255
    end

    @sum_power += power
    @sum_sum_power += @sum_power
    @v_e5 = @sum_power
    @x_e5 = @sum_sum_power / 1000.0

    @counter += 1
    if @counter % 30 == 0
	  now = (($timer.now - $start_time) / 1000).floor
	  $serial.puts("#{now},#{power},#{omega_i},#{@theta_i}")
    end

    ## now X and Y is same
    return power, power
  end
end


$serial = Serial.new

MESURE_COUNTS = 45 ## 定数
gyro = Gyro.new() ## Gyro.new(Port::XX) ?

# in1, in2, enable, pwm0or1
motor_left = Motor.new(5, 6, 12, 0)
motor_right = Motor.new(16, 20, 19, 1)

$timer = SystemTimer.new
$start_time = $timer.now

balancer = Balancer.new(80, 800, 55, 20)
# balancer = Balancer.new(80, 0, 0, 0)

# $serial.puts("time,power,omegaI,thetaI,theta,omega,distance,vE5")
$serial.puts("time,power,omega,theta")


loop do
  gyro_value = gyro.measure(Gyro::Y, MESURE_COUNTS)

  power_left, power_right = balancer.calculate(gyro_value)

  # motorに渡す
  motor_left.power = power_left   ## powerがマイナスなら逆転
  motor_right.power = power_right

  #now = ((timer.now - start_time) / 1000).floor
  #serial.puts("#{now},#{power},#{omega_i},#{theta_i/286},#{t},#{o},#{d/200},#{v_e5}")
end
