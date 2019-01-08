function steering_matrix = create_steeringMatrix(Model_paras)


steering_matrix = complex(zeros(Model_paras.num_antenna,length(Model_paras.angles)));

% 相邻天线之间距离 单位：m
antenna_space = (Model_paras.speed_light/Model_paras.frequency) * Model_paras.antenna_space_ofwaveLen;


for K = 1:length(Model_paras.angles)
    for M = 1:Model_paras.num_antenna
        steering_matrix(M,K) = exp(-1i * 2*pi * (M-1) * antenna_space * cos(Model_paras.angles(K) * pi / 180) * Model_paras.frequency / Model_paras.speed_light);
    end
end

% 将计算结果保存到文件
file_name = '.\data_files\steering_matrix.mat';

save(file_name,'steering_matrix') ;

end
