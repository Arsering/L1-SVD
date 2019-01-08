function [angle_info_output,inter_params_L1SVD] = simulation_environment(num_samples,SNR,angle_info_input,has_noise,confidence_interval,correlation_coefficient)
%% 
% inter_params_L1SVD 中包含：
%         noise:添加到模拟信号的噪声矩阵
%         variance:噪声的方差
%         V;对模拟信号（CSI）SVD后得到的右矩阵
%         regulari_param:求得的regularization_parameter值
%         pseudo_spectrum:精度为1时的伪谱


%% 确定参数

Model_paras.precision = 0.01; % 最大精度
Model_paras.now_precision = 1; % 当前精度
Model_paras.num_interval = 2; % 下一轮取多少区间
Model_paras.frequency = 3 * 10^9; % 工作频率
Model_paras.antenna_space_ofwaveLen = 0.5; % 相邻天线之间的距离（表示为与波长的关系）
Model_paras.num_antenna = 8; % 天线的个数
Model_paras.speed_light = 3 * 10^8; % 光速
Model_paras.has_noise = has_noise; % 为1则添加噪声 否则不添加噪声
Model_paras.SNR = SNR; % 信噪比
Model_paras.num_samples = num_samples; % 时域样本个数
Model_paras.angles = 0:Model_paras.now_precision:180; % 备选角度
Model_paras.angle_info_input = angle_info_input; % 模拟信号的信源对应的角度
Model_paras.correlation_coefficient = correlation_coefficient; % 不同信源产生的信号之间的相关度
Model_paras.complex_gain = create_complexGain(Model_paras); % 根据给定的相关系数随机生成complex_gain
Model_paras.confidence_interval = confidence_interval; % 生成regularization_parameter时要用


%% 产生符合要求的CSI数据 之后利用L1-SVD算法解出相应的AOA

    % 生成每个AP对应的CSI矩阵和它所接收到的路径信息
    [CSI,variance,noise] = create_CSI_by_angle(Model_paras);
    
    % 使用L1-SVD算法
    [angle_info_output,inter_params_L1SVD] = L1_SVD(Model_paras,CSI,variance);
    inter_params_L1SVD.noise = noise;
    
%     % 使用MUSIC（未经spatial-smoothing）
%     [fff,y_MUSIC] = MUSIC_Origin(CSI(:,:),Model_paras,length(Model_paras.angle_info_input));
% 
%     % 输出使用两种方法得到的伪谱图
%     figure
%     hold on;
%     plot(Model_paras.angles,inter_params_L1SVD.pseudo_spectrum,'b-','DisplayName','L1-SVD');
%     plot(0:Model_paras.precision:180,y_MUSIC,'m--','DisplayName','MUSIC');
%     legend();
%     xlabel('angle（degree）');  %x轴坐标描述
%     ylabel('pseudo-spectrum'); %y轴坐标描述
%     hold off;

end

%% 生成特定的complex_gain
function complex_gain = create_complexGain(Model_paras)

% 生成初始的协方差矩阵
signalCovMat = 1*eye(length(Model_paras.angle_info_input));

% 为了简便 我将任意两个不同信源之间的相关系数都置同一个值
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

% 为了简便才如此 可以修改（无论修改与否，都不影响我们的实验效果）
complex_gain = exp(1i * complex_gain);

end
    