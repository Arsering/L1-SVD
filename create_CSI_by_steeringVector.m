function [CSI,variance,noise] = create_CSI_by_steeringVector(Model_paras)
%% ͨ��steering_matrix����ģ������

% ����ģ��CSI
CSI = complex(zeros(Model_paras.num_antenna,Model_paras.num_samples));

for T = 1:Model_paras.num_samples
    CSI(:,T) = Model_paras.steeringMatrix(:,Model_paras.angle_info_input) * Model_paras.complex_gain(:,T);
end

% �������
if Model_paras.has_noise == 1
    [CSI,variance,noise] = my_awgn(CSI,Model_paras.SNR);
end

end
