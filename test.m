num_samples = 100; % ��������
SNR = 20; % �����
angle_info_input =[42.45,63.78]; % ���ģ���źŵ���Դ��Ӧ�������
has_noise = 1; % Ϊ1��������� �����������
confidence_interval = 0.99; % ����regularization_parameterʱ�����Ŷ�
correlation_coefficient = 0.1; % ��ͬ�Ƕȵ����ϵ��
angle_info_output = simulation_environment(num_samples,SNR,angle_info_input,has_noise,confidence_interval,correlation_coefficient)