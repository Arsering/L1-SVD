function [angle_info_output,inter_params] = L1_SVD(Model_paras,CSI,variance)
% 模拟信号中的添加的噪声的方差 用于生成regularization_parameter
inter_params.variance = variance;

% 得到时域样本数
[~,T] = size(CSI);

% 得到所用天线个数
num_antenna = Model_paras.num_antenna;

% 计算CSI的SVD
[~,L,V] = svd(CSI);
inter_params.V = V;

% 确定生成模拟信号的信源个数
num_source = length(Model_paras.angle_info_input);

% 确定K的大小
if size(L,1) < num_source 
    K = size(L,1);
else
    K = num_source;
end
inter_params.K = K;

% 获得Ysv矩阵
D_K = [eye(K,K),zeros(K,T-K)]';
CSI_SV = CSI * V * D_K;
inter_params.D_K = D_K;

% 得到每个备选角度对应的steering_vector
steeringMatrix = create_steeringMatrix(Model_paras);

% 得到备选角度的总个数
num_angle = length(Model_paras.angles);

%% (版本一：在信噪比比较大的时候可以自动确定regularization_parameter)
% 使用CVX工具箱解目标函数

% 计算regularization_parameter
regulari_param = compute_regualariParam(Model_paras.confidence_interval,variance,num_antenna,K);
inter_params.regulari_param = regulari_param;

cvx_begin quiet
    variable S_sv(num_angle,K) complex
    minimize(target_function(S_sv))
    subject to
        norm(CSI_SV - steeringMatrix * S_sv,'fro') <= regulari_param 
cvx_end

% 
% % %% (版本二：手动输入regularization_parameter)
% % sumVec = ones(1,num_angle);
% % 
% % cvx_begin quiet
% %     variable S_sv(num_angle,K) complex
% %     variables p q r(num_angle,1)
% % 
% %     minimize(p+regulari_param*q)
% %     subject to
% %         norm(CSI_SV - Model_paras.steeringMatrix * S_sv,'fro') <= p;
% %         
% %         sumVec*r <= q;
% %         
% %         for idx = 1: num_angle
% %             norm(S_sv(idx,:)) <= r(idx);
% %         end
% % cvx_end
% % 


% 生成伪谱
pseudo_spectrum = abs(S_sv(:,1)).^2;
inter_params.pseudo_spectrum = pseudo_spectrum;

%%  生成二维图像

precision = Model_paras.now_precision; % 得到当前轮次对应的精度
start_index = 1;
end_index = 2;
figs = []; % 保存每个子图对应的起点和尾点的下标值

% 得到每个子图对应的起点和尾点的下标值
while end_index <= length(Model_paras.angles)

    if Model_paras.angles(end_index) - Model_paras.angles(end_index-1) > precision*2 || end_index == length(Model_paras.angles)
        figs = [figs;[start_index,end_index-1]];
        start_index = end_index;
    end
    end_index = end_index + 1;
end

% 输出图像
figure
hold on;
for F = 1:size(figs,1)
    subplot(1,size(figs,1),F);
    plot(Model_paras.angles(figs(F,1):figs(F,2)),pseudo_spectrum(figs(F,1):figs(F,2)),'b-','DisplayName','L1-SVD','LineWidth',1);
    legend();
    title(['Precision = ',num2str(precision)]);
    xlabel('angle（degree）');  %x轴坐标描述
    ylabel('pseudo-spectrum'); %y轴坐标描述
end
hold off;


%% 寻找前num_source个模最大值对应的下标 
angle_info_output = zeros(1,num_source);
max_N_value = zeros(1,num_source);

if size(figs,1) == 1
    for k = 2:length(pseudo_spectrum)-1
        step = [1,-1];
        mark = 1;
        % 确定是否为极大值
        for t = 1:length(step)
            if pseudo_spectrum(step(t) + k) > pseudo_spectrum(k)
                mark = 0;
                break;
            end
        end

        if mark == 1
            index_tmp = minI(max_N_value);
            if angle_info_output(index_tmp) == 0 || max_N_value(index_tmp) < pseudo_spectrum(k)
                angle_info_output(index_tmp) = k;
                max_N_value(index_tmp) = pseudo_spectrum(k);
            end
        end
    end
else
    for f = 1:size(figs,1)
        sub_fig = pseudo_spectrum(figs(f,1):figs(f,2));
        tmp = find(sub_fig == max(sub_fig)); % 注意此处可能会找到多个值 以后要进行修改
        angle_info_output(f) = tmp(1);
        if f ~= 1
            angle_info_output(f) = angle_info_output(f) + figs(f-1,2);
        end
    end
end
    
angle_info_output = sort(Model_paras.angles(angle_info_output));

precision = Model_paras.now_precision;
Model_paras.now_precision = precision / 10;

% 如果当前精度不是我们要求的最大精度 则递归以达到要求的精度
if precision > Model_paras.precision
    window = precision * Model_paras.num_interval;
    Model_paras.num_interval = Model_paras.num_interval*2; % 当精度越大时 貌似采样区间大点好
    
    % 重新生成我们的备选角度数组
    Model_paras.angles = [];
    for L = 1:length(angle_info_output)
        Model_paras.angles = [Model_paras.angles,max(0,angle_info_output(L)-window):Model_paras.now_precision:min(180,angle_info_output(L)+window)];
    end
    
    % 前一步生成的备选角度中会存在重复值和乱序现象
    Model_paras.angles = sort(unique(Model_paras.angles));
    
    % 递归调用L1_SVD算法
    angle_info_output = L1_SVD(Model_paras,CSI,variance);
end


end

%% 计算regularization_parameter
function regulari_param = compute_regualariParam(confience_interval,variance,M,K)
    regulari_param = chi2inv(confience_interval,M * K); % * variance;% 这里我也不知道要不要乘以方差
end

%% 求得输入数组中最小元素的下标

function index = minI(input)
    index  = 1;
    for k = 2:length(input)
        if input(k) < input(index)
            index = k;
        end
    end
end

