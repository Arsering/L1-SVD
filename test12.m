%% 本测试展现 不同信源对应的角度之间的距离与我们的准确度之间的关系


num_samples = 200; % 样本总数
SNR = 10; % 信噪比
angles = 0:1:180; % 备选角度
angle_info_input = 43; % 组成模拟信号的信源对应的入射角
has_noise = 1; % 为1则添加噪声 否则不添加噪声
confidence_interval = 0.99; % 生成regularization_parameter时的置信度
correlation_coefficient = 0; % 不同角度的相关系数
mark = {'r-','g--','b:','y-.','m-','c--','k:'};

bigOne_error = zeros(1,60);
smallOne_error = zeros(1,60);

parfor separation = 1:60
    for sample = 1:50
        angle_info = [angle_info_input,angle_info_input + separation*2];
        angle_info_output = simulation_environment(num_samples,SNR,angles,angle_info,has_noise,confidence_interval,correlation_coefficient);
        smallOne_error(separation) = smallOne_error(separation) + abs(min(angle_info_output) - angle_info_input);
        bigOne_error(separation) = bigOne_error(separation) + abs(max(angle_info_output) - angle_info_input - separation*2);
    end

end

smallOne_error = smallOne_error / 50;
bigOne_error = bigOne_error / 50;

mark = {'r-+' 'g--o' 'b*:' 'c-.s' 'm-p' 'y--h'}; % 不同折线图具有不同的颜色、线型、点标记
hold on;
plot(2:2:120,smallOne_error,mark{1},'DisplayName','Source 1 position bias','LineWidth',1);
plot(2:2:120,bigOne_error,mark{2},'DisplayName','Source 1 position bias','LineWidth',1);
legend();
hold off;