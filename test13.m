num_samples = 200; % 样本总数
SNR = -28:2:30; % 信噪比
angle_info_input =[42.83,73.33]; % 组成模拟信号的信源对应的入射角
has_noise = 1; % 为1则添加噪声 否则不添加噪声
confidence_interval = 0.99; % 生成regularization_parameter时的置信度
correlation_coefficient = 0.5; % 不同角度的相关系数
num_experiment = 50;
various_error = zeros(1,length(SNR));
for s = 1:length(SNR)
    for e = 1:num_experiment
        angle_info_output = simulation_environment(num_samples,SNR(s),angle_info_input,has_noise,confidence_interval,correlation_coefficient);
        various_error(s) = various_error(s) + (max(angle_info_output) - angle_info_input(2))^2 + (min(angle_info_output) - angle_info_input(1))^2;
    end
end

various_error = various_error / (num_experiment * 2);

plot(SNR,various_error,'m-','DisplayName','L1-SVD');
legend();
xlabel('SNR(dB)');  %x轴坐标描述
ylabel('Various'); %y轴坐标描述
