%% ������չ�� �ڲ�ͬ�����������������������NVD�Ĺ�ϵ
num_samples = 200; % ��������
SNR = 10; % �����
angles = 0:1:180; % ��ѡ�Ƕ�
angle_info_input =[61,81]; % ���ģ���źŵ���Դ��Ӧ�������
has_noise = 1; % Ϊ1��������� �����������
confidence_interval = 0.99; % ����regularization_parameterʱ�����Ŷ�
correlation_coefficient = 0; % ��ͬ�Ƕȵ����ϵ��
% mark = {'r-','g--','b:','y-.','m-','c--','k:'};

num_differentAngle = 10;
num_sampleN = 250;
minimum = zeros(num_differentAngle,length(-70:10:100));
average = zeros(num_differentAngle,length(-70:10:100));
maximum = zeros(num_differentAngle,length(-70:10:100));
SNR = -70:10:100;

for S = 1:length(SNR)
    for A = 1:num_differentAngle
        angle_info_input = round(rand(1,3) * 179) + 1;
        tmp = zeros(1,num_sampleN);
        for k =1:num_sampleN
            [~,inter_params_L1SVD] = simulation_environment(num_samples,SNR(S),angles,angle_info_input,has_noise,confidence_interval,correlation_coefficient);
            
            n = inter_params_L1SVD.noise * inter_params_L1SVD.V * inter_params_L1SVD.D_K;
            variance = var(inter_params_L1SVD.noise(:));
            
            tmp(k) = norm(n(:),2)/sqrt(variance);
        end
        minimum(A,S) = min(tmp);
        average(A,S) = sum(tmp)/numel(tmp);
        maximum(A,S) = max(tmp);
    end
end

mark = {'r-+' 'g--o' 'b*:' 'c-.s' 'm-p' 'y--h'}; % ��ͬ����ͼ���в�ͬ����ɫ�����͡�����
hold on;
for A = 1:num_differentAngle
    if A == 1 
        f1 = plot(-70:10:100,minimum(A,:),mark{1},'DisplayName','min','LineWidth',1);
        f2 = plot(-70:10:100,average(A,:),mark{2},'DisplayName','average','LineWidth',1);
        f3 = plot(-70:10:100,maximum(A,:),mark{3},'DisplayName','max','LineWidth',1);
    else
        plot(-70:10:100,minimum(A,:),mark{1},'LineWidth',1);
        plot(-70:10:100,average(A,:),mark{2},'LineWidth',1);
        plot(-70:10:100,maximum(A,:),mark{3},'LineWidth',1);
    end
end
legend([f1,f2,f3]);
xlabel('SNR(dB)');  %x����������
ylabel('Noise norm ratio'); %y����������
hold off;
