function [time_vct, IR] = GetRIR()
    fs = 44100;
    sig_len = 1;
    fs1 = 1;
    fs2 = 22050;
    avg = 3;
    dev = [];
    in_ch = 1;
    out_ch = 1;


    T = sig_len;
    % Create the swept sine tone
    w1 = 2*pi*fs1;
    w2 = 2*pi*fs2;
    K = T*w1/log(w2/w1);
    L = T/log(w2/w1);
    t = linspace(0,T-1/fs,fs*T);
    sweep = sin(K*(exp(t/L) - 1));
    ramp_down = 1:-.004:0;
    sweep(end-250:end) = sweep(end-250:end).*ramp_down;
    output_sweep = sweep;

    position = 1;
    while position<avg+2
    output_sweep = cat(2,output_sweep,sweep);
    position = position+1;
    end
    multi_sweep = output_sweep;
     for idx = 1:out_ch-1
    multi_sweep = cat(1,multi_sweep,output_sweep);
     end
    multi_sweep = multi_sweep.*.04;

    pahandle = PsychPortAudio('Open', dev, 3,0,fs,[out_ch, in_ch]);
    PsychPortAudio('FillBuffer', pahandle, multi_sweep);
    PsychPortAudio('GetAudioData', pahandle ,ceil(size(multi_sweep,2)/fs)); 
    PsychPortAudio('Start', pahandle);
    WaitSecs(size(output_sweep,2)/fs);
    PsychPortAudio('Stop', pahandle);
    [signal] = PsychPortAudio('GetAudioData', pahandle ,[],[],[]);
    PsychPortAudio('Close');
    signal = signal';
    %signal_avg = signal;
    %figure;plot(signal)

    %  %-------Average-----------------------------------

    %  %len = fs*T;
    % signal_array = zeros(len,avg+2,in_ch);
    % pos = 1;
    % for idx = 1:len:length(signal)-len
    %     signal_array(:,pos,:) = signal(idx:idx+len-1,:);
    %     pos = pos +1;
    % end
    % signal_avg = zeros(len,in_ch);
    % for idx = 1:in_ch
    % signal_avg(:,idx) = mean(signal_array(:,2:avg+1,idx),2);
    % end

    % %----------Deconvolve--------------------------------
    %double_IR = zeros(length(signal_avg)+size(sweep,2)-1,1);
    %IR = zeros(len,in_ch);
    len = length(sweep);
    IR = zeros(len,in_ch);
    for idx = 1:in_ch
    Y=fft(signal(:,idx),(length(signal)+size(sweep,2)-1));   
     H=fft(sweep',(length(signal)+size(sweep,2)-1));   
     G=Y./(H);   
     multi_IR(:,idx)=ifft(G,'symmetric');
     for idx_a = len:len:length(signal)-1.5.*len
     IR(:,idx) = IR(:,idx)+multi_IR(idx_a:idx_a+len-1,idx);  
     end
     %figure;plot(multi_IR);
    end
    ms = fs/1000;

    %  [null,latency] = max(IR(ms:end,in_ch));
    %  latency = latency+ms;
    %  IR = IR(latency+5:(T*fs)-latency-5,:);


     %if get(handles.polar_check,'Value') ==0
       IR = IR./(1.1.*max(max(abs(IR))));
    % end


    len = size(IR,1);
    delta_t = 1/fs;
    time_vct = 0:delta_t:(len-1)*delta_t;
    time_vct = time_vct';
end

