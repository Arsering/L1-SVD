function [angle_info_output,inter_params_L1SVD] = simulation_environment(num_samples,SNR,angle_info_input,has_noise,confidence_interval,correlation_coefficient)
%% 
% inter_params_L1SVD �а�����
%         noise:��ӵ�ģ���źŵ���������
%         variance:�����ķ���
%         V;��ģ���źţ�CSI��SVD��õ����Ҿ���
%         regulari_param:��õ�regularization_parameterֵ
%         pseudo_spectrum:����Ϊ1ʱ��α��


%% ȷ������

Model_paras.precision = 0.01; % ��󾫶�
Model_paras.now_precision = 1; % ��ǰ����
Model_paras.num_interval = 2; % ��һ��ȡ��������
Model_paras.frequency = 3 * 10^9; % ����Ƶ��
Model_paras.antenna_space_ofwaveLen = 0.5; % ��������֮��ľ��루��ʾΪ�벨���Ĺ�ϵ��
Model_paras.num_antenna = 8; % ���ߵĸ���
Model_paras.speed_light = 3 * 10^8; % ����
Model_paras.has_noise = has_noise; % Ϊ1��������� �����������
Model_paras.SNR = SNR; % �����
Model_paras.num_samples = num_samples; % ʱ����������
Model_paras.angles = 0:Model_paras.now_precision:180; % ��ѡ�Ƕ�
Model_paras.angle_info_input = angle_info_input; % ģ���źŵ���Դ��Ӧ�ĽǶ�
Model_paras.correlation_coefficient = correlation_coefficient; % ��ͬ��Դ�������ź�֮�����ض�
Model_paras.complex_gain = create_complexGain(Model_paras); % ���ݸ��������ϵ���������complex_gain
Model_paras.confidence_interval = confidence_interval; % ����regularization_parameterʱҪ��


%% ��������Ҫ���CSI���� ֮������L1-SVD�㷨�����Ӧ��AOA

    % ����ÿ��AP��Ӧ��CSI������������յ���·����Ϣ
    [CSI,variance,noise] = create_CSI_by_angle(Model_paras);
    
    % ʹ��L1-SVD�㷨
    [angle_info_output,inter_params_L1SVD] = L1_SVD(Model_paras,CSI,variance);
    inter_params_L1SVD.noise = noise;
    
%     % ʹ��MUSIC��δ��spatial-smoothing��
%     [fff,y_MUSIC] = MUSIC_Origin(CSI(:,:),Model_paras,length(Model_paras.angle_info_input));
% 
%     % ���ʹ�����ַ����õ���α��ͼ
%     figure
%     hold on;
%     plot(Model_paras.angles,inter_params_L1SVD.pseudo_spectrum,'b-','DisplayName','L1-SVD');
%     plot(0:Model_paras.precision:180,y_MUSIC,'m--','DisplayName','MUSIC');
%     legend();
%     xlabel('angle��degree��');  %x����������
%     ylabel('pseudo-spectrum'); %y����������
%     hold off;

end

%% �����ض���complex_gain
function complex_gain = create_complexGain(Model_paras)

% ���ɳ�ʼ��Э�������
signalCovMat = 1*eye(length(Model_paras.angle_info_input));

% Ϊ�˼�� �ҽ�����������ͬ��Դ֮������ϵ������ͬһ��ֵ
for t = 1:length(Model_paras.angle_info_input)
    for k = 1:length(Model_paras.angle_info_input)
        if t == k
            continue;
        else
            signalCovMat(t,k) = Model_paras.correlation_coefficient;
        end
    end
end

complex_gain = mvnrnd(zeros(length(Model_paras.angle_info_input), 1), signalCovMat, Model_paras.num_samples).';

% Ϊ�˼������ �����޸ģ������޸���񣬶���Ӱ�����ǵ�ʵ��Ч����
complex_gain = exp(1i * complex_gain);

end
    