function [time_vct, IR, Y] = GetRIR()
    FS = 44100;
    SIG_LEN = 1;
    FS1 = 1;
    FS2 = 22050;
    AVG = 3;
    DEVICE = [];
    IN_CHNL = 1;
    OUT_CHNL = 1;
    T = SIG_LEN;

    % Create the swept sine tone
    w1 = 2 * pi * FS1;
    w2 = 2 * pi * FS2;
    K = T * w1 / log(w2 / w1);
    L = T / log(w2 / w1);
    t = linspace(0, T-1 / FS, FS * T);
    sweep = sin(K * (exp(t / L) - 1));
    ramp_down = 1:-.004:0;
    sweep(end - 250:end) = sweep(end - 250:end) .* ramp_down;
    output_sweep = sweep;

    position = 1;
    while position < AVG + 2
        output_sweep = cat(2, output_sweep, sweep);
        position = position + 1;
    end

    multi_sweep = output_sweep;
    for idx = 1 : OUT_CHNL - 1
        multi_sweep = cat(1, multi_sweep, output_sweep);
    end

    multi_sweep = multi_sweep.*.04;
    pahandle = PsychPortAudio('Open', DEVICE, 3,0,FS,[OUT_CHNL, IN_CHNL]);
    PsychPortAudio('FillBuffer', pahandle, multi_sweep);
    PsychPortAudio('GetAudioData', pahandle ,ceil(size(multi_sweep,2)/FS)); 
    PsychPortAudio('Start', pahandle);
    WaitSecs(size(output_sweep,2)/FS);
    PsychPortAudio('Stop', pahandle);
    [signal] = PsychPortAudio('GetAudioData', pahandle ,[],[],[]);
    PsychPortAudio('Close');
    signal = signal';

    % %----------Deconvolve--------------------------------
    len = length(sweep);
    IR = zeros(len,IN_CHNL);
    for idx = 1:IN_CHNL
        Y=fft(signal(:,idx),(length(signal)+size(sweep,2)-1));   
        H=fft(sweep',(length(signal)+size(sweep,2)-1));   
        G=Y./(H);   
        multi_IR(:,idx)=ifft(G,'symmetric');
        for idx_a = len:len:length(signal)-1.5.*len
            IR(:,idx) = IR(:,idx)+multi_IR(idx_a:idx_a+len-1,idx);  
        end
    end

    ms = round(FS/1000);
    [~,latency] = max(IR(ms:end,IN_CHNL));
    latency = latency+ms;
    IR = IR(latency+5:(T*FS)-latency-5,:);

    IR = IR./(1.1.*max(max(abs(IR))));

    len = size(IR,1);
    delta_t = 1/FS;
    time_vct = 0:delta_t:(len-1)*delta_t;
    time_vct = time_vct';
end

