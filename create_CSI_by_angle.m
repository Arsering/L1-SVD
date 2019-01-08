function [CSI,variance,noise] = create_CSI_by_angle(Model_paras)
%% ͨ��steering_matrix����ģ������

% ��������֮����� ��λ��m
antenna_space = (Model_paras.speed_light/Model_paras.frequency) * Model_paras.antenna_space_ofwaveLen;

% ����ģ��CSI
CSI = complex(zeros(Model_paras.num_antenna,Model_paras.num_samples));

for T = 1:Model_paras.num_samples
    for A = 1:length(Model_paras.angle_info_input)
    CSI(:,T) = CSI(:,T)...
        + exp(-1i * 2*pi * (0:Model_paras.num_antenna-1) * antenna_space * cos(Model_paras.angle_info_input(A) * pi / 180) * Model_paras.frequency / Model_paras.speed_light).'...
        * Model_paras.complex_gain(A,T);
    end
end

% �������
if Model_paras.has_noise == 1
    [CSI,variance,noise] = my_awgn(CSI,Model_paras.SNR);
end

end
