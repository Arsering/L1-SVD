num_samples = 200; % ��������
SNR = -28:2:30; % �����
angle_info_input =[42.83,73.33]; % ���ģ���źŵ���Դ��Ӧ�������
has_noise = 1; % Ϊ1��������� �����������
confidence_interval = 0.99; % ����regularization_parameterʱ�����Ŷ�
correlation_coefficient = 0.5; % ��ͬ�Ƕȵ����ϵ��
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
xlabel('SNR(dB)');  %x����������
ylabel('Various'); %y����������
