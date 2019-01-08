%% ������չ�� ��ͬ��Դ��Ӧ�ĽǶ�֮��ľ��������ǵ�׼ȷ��֮��Ĺ�ϵ


num_samples = 200; % ��������
SNR = 10; % �����
angles = 0:1:180; % ��ѡ�Ƕ�
angle_info_input = 43; % ���ģ���źŵ���Դ��Ӧ�������
has_noise = 1; % Ϊ1��������� �����������
confidence_interval = 0.99; % ����regularization_parameterʱ�����Ŷ�
correlation_coefficient = 0; % ��ͬ�Ƕȵ����ϵ��
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

mark = {'r-+' 'g--o' 'b*:' 'c-.s' 'm-p' 'y--h'}; % ��ͬ����ͼ���в�ͬ����ɫ�����͡�����
hold on;
plot(2:2:120,smallOne_error,mark{1},'DisplayName','Source 1 position bias','LineWidth',1);
plot(2:2:120,bigOne_error,mark{2},'DisplayName','Source 1 position bias','LineWidth',1);
legend();
hold off;