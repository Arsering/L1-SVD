num_samples = 100; % 样本总数
SNR = 20; % 信噪比
angle_info_input =[42.45,63.78]; % 组成模拟信号的信源对应的入射角
has_noise = 1; % 为1则添加噪声 否则不添加噪声
confidence_interval = 0.99; % 生成regularization_parameter时的置信度
correlation_coefficient = 0.1; % 不同角度的相关系数
angle_info_output = simulation_environment(num_samples,SNR,angle_info_input,has_noise,confidence_interval,correlation_coefficient)