function [angle_info_output,inter_params] = L1_SVD(Model_paras,CSI,variance)
% ģ���ź��е���ӵ������ķ��� ��������regularization_parameter
inter_params.variance = variance;

% �õ�ʱ��������
[~,T] = size(CSI);

% �õ��������߸���
num_antenna = Model_paras.num_antenna;

% ����CSI��SVD
[~,L,V] = svd(CSI);
inter_params.V = V;

% ȷ������ģ���źŵ���Դ����
num_source = length(Model_paras.angle_info_input);

% ȷ��K�Ĵ�С
if size(L,1) < num_source 
    K = size(L,1);
else
    K = num_source;
end
inter_params.K = K;

% ���Ysv����
D_K = [eye(K,K),zeros(K,T-K)]';
CSI_SV = CSI * V * D_K;
inter_params.D_K = D_K;

% �õ�ÿ����ѡ�Ƕȶ�Ӧ��steering_vector
steeringMatrix = create_steeringMatrix(Model_paras);

% �õ���ѡ�Ƕȵ��ܸ���
num_angle = length(Model_paras.angles);

%% (�汾һ��������ȱȽϴ��ʱ������Զ�ȷ��regularization_parameter)
% ʹ��CVX�������Ŀ�꺯��

% ����regularization_parameter
regulari_param = compute_regualariParam(Model_paras.confidence_interval,variance,num_antenna,K);
inter_params.regulari_param = regulari_param;

cvx_begin quiet
    variable S_sv(num_angle,K) complex
    minimize(target_function(S_sv))
    subject to
        norm(CSI_SV - steeringMatrix * S_sv,'fro') <= regulari_param 
cvx_end

% 
% % %% (�汾�����ֶ�����regularization_parameter)
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


% ����α��
pseudo_spectrum = abs(S_sv(:,1)).^2;
inter_params.pseudo_spectrum = pseudo_spectrum;

%%  ���ɶ�άͼ��

precision = Model_paras.now_precision; % �õ���ǰ�ִζ�Ӧ�ľ���
start_index = 1;
end_index = 2;
figs = []; % ����ÿ����ͼ��Ӧ������β����±�ֵ

% �õ�ÿ����ͼ��Ӧ������β����±�ֵ
while end_index <= length(Model_paras.angles)

    if Model_paras.angles(end_index) - Model_paras.angles(end_index-1) > precision*2 || end_index == length(Model_paras.angles)
        figs = [figs;[start_index,end_index-1]];
        start_index = end_index;
    end
    end_index = end_index + 1;
end

% ���ͼ��
figure
hold on;
for F = 1:size(figs,1)
    subplot(1,size(figs,1),F);
    plot(Model_paras.angles(figs(F,1):figs(F,2)),pseudo_spectrum(figs(F,1):figs(F,2)),'b-','DisplayName','L1-SVD','LineWidth',1);
    legend();
    title(['Precision = ',num2str(precision)]);
    xlabel('angle��degree��');  %x����������
    ylabel('pseudo-spectrum'); %y����������
end
hold off;


%% Ѱ��ǰnum_source��ģ���ֵ��Ӧ���±� 
angle_info_output = zeros(1,num_source);
max_N_value = zeros(1,num_source);

if size(figs,1) == 1
    for k = 2:length(pseudo_spectrum)-1
        step = [1,-1];
        mark = 1;
        % ȷ���Ƿ�Ϊ����ֵ
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
        tmp = find(sub_fig == max(sub_fig)); % ע��˴����ܻ��ҵ����ֵ �Ժ�Ҫ�����޸�
        angle_info_output(f) = tmp(1);
        if f ~= 1
            angle_info_output(f) = angle_info_output(f) + figs(f-1,2);
        end
    end
end
    
angle_info_output = sort(Model_paras.angles(angle_info_output));

precision = Model_paras.now_precision;
Model_paras.now_precision = precision / 10;

% �����ǰ���Ȳ�������Ҫ�����󾫶� ��ݹ��ԴﵽҪ��ľ���
if precision > Model_paras.precision
    window = precision * Model_paras.num_interval;
    Model_paras.num_interval = Model_paras.num_interval*2; % ������Խ��ʱ ò�Ʋ����������
    
    % �����������ǵı�ѡ�Ƕ�����
    Model_paras.angles = [];
    for L = 1:length(angle_info_output)
        Model_paras.angles = [Model_paras.angles,max(0,angle_info_output(L)-window):Model_paras.now_precision:min(180,angle_info_output(L)+window)];
    end
    
    % ǰһ�����ɵı�ѡ�Ƕ��л�����ظ�ֵ����������
    Model_paras.angles = sort(unique(Model_paras.angles));
    
    % �ݹ����L1_SVD�㷨
    angle_info_output = L1_SVD(Model_paras,CSI,variance);
end


end

%% ����regularization_parameter
function regulari_param = compute_regualariParam(confience_interval,variance,M,K)
    regulari_param = chi2inv(confience_interval,M * K); % * variance;% ������Ҳ��֪��Ҫ��Ҫ���Է���
end

%% ���������������СԪ�ص��±�

function index = minI(input)
    index  = 1;
    for k = 2:length(input)
        if input(k) < input(index)
            index = k;
        end
    end
end

