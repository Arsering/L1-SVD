function [path_info_output,samples] = MUSIC_Origin(CSI,Model_paras,signal_space)
%% 最原始的MUSIC，没有进行平滑
[row,column] = size(CSI);

%% 可以选择使用spatial smoothing
% row = floor(WLAN_paras.num_antenna/2);
% column = WLAN_paras.num_antenna + 1 - row;
% 
% smoothed_CSI = complex(zeros(row,column));
% 
% if size(CSI,1) < size(CSI,2)
%     CSI = CSI.';
% end
% 
% % smoothing CSI
% for k = 1:column
%     smoothed_CSI(:,k) = CSI(k:(k+row-1),1);
% end
%% 

% 计算CSI的特征值及其对应的特征向量
correlation_matrix = CSI * CSI';
[E,D] = eig(correlation_matrix);

 % 找到noise_space对应的特征向量
[~,indx] = sort(diag(D),'descend');
eigenvects = E(:,indx);
noise_eigenvects = eigenvects(:,(signal_space+1):end);

% 计算相邻天线之间的距离
antenna_space = (Model_paras.speed_light/Model_paras.frequency) * Model_paras.antenna_space_ofwaveLen; % 相邻天线之间距离 单位：m

%确定采样点
X = (0:Model_paras.precision:180);

samples = complex(zeros(1,length(X)));

%采样
for t = 1:length(X)
    Steering_Vector = complex(zeros(row,1));
    for m = 0:1:row-1
        Steering_Vector(m+1) = exp(-1i * 2*pi * antenna_space * cos(X(t) * pi / 180) * Model_paras.frequency / Model_paras.speed_light)^m;
    end
    samples(t) = 1/sum(abs(noise_eigenvects' * Steering_Vector).^2,1);

end

samples = 20*log10(samples);
%% 生成二维图像

figure
plot(X,samples,'m--');
title('MUSIC(no_smoothing)');
xlabel('angle（degree）');  %x轴坐标描述
ylabel('pseudo-spectrum(dB)'); %y轴坐标描述

% % 输出特定点的采样值
% Steering_Vector = complex(zeros(row,1));
% for m = 0:1:row-1
%     Steering_Vector(m+1) = exp(-1i * 2*pi * antenna_space * cos(Model_paras.path_info_input(2,1) * pi / 180) * Model_paras.frequency / Model_paras.speed_light)^m;
% end
% 1/sum(abs(noise_eigenvects' * Steering_Vector).^2,1)

%% 
%定义存储求得的AOA TOF的矩阵
path_info_output = zeros(1,signal_space);
max_N_value = zeros(1,signal_space);

%寻找前signal_space个极大值点
for m = 2:length(samples)-1
    steps = [-1,1];
    scopeX = length(X);
    for S = 1:length(steps)
        tmpX = m + steps(S);
        mark = 1;
        if samples(m) < samples(tmpX)
            mark = 0;
            break;
        end
    end
    if mark == 1
        tmp_index = minI(max_N_value);
        if max_N_value(tmp_index) < samples(m)
            path_info_output(tmp_index) = X(m);
            max_N_value(tmp_index) = samples(m);
        end
    end
end

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

