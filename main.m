[t, ir] = GetRIR();
%[da, db, rt] = getDecayFit(t, ir);

[t_bins, d_bins] = getTimeBins(t, ir);
figure;
plot(d_bins);

function [a, b, r] = getDecayFit(t, impulse_response)
    DECAYFIT_MEDIANS = 1000;
    DECAYFIT_IGNORE_AMP_FACTOR = 100;

    clean = movmedian(abs(impulse_response), DECAYFIT_MEDIANS);
    clean = clean - min(clean);
    %plot(clean);
    
    [~, max_i] = max(clean);
    tail = find(clean(max_i:end) < clean(max_i)/DECAYFIT_IGNORE_AMP_FACTOR);
    tail_start = tail(1) + max_i;
    
    f = fit(t(max_i:tail_start), clean(max_i:tail_start), 'exp1');
    %plot(f, t(max_i:tail_start), clean(max_i:tail_start));
    v = coeffvalues(f);
    a = v(1);
    b = v(2);
    
    r = t(tail_start) - t(max_i);
end

function [t_bins, d_bins] = getTimeBins(t, impulse_response)
    NUM_BINS = 20;
    
    t_bins = zeros(1, NUM_BINS);
    d_bins = zeros(1, NUM_BINS);
    clean = abs(impulse_response);
    total = sum(clean);
    section = total/NUM_BINS;
    target = section;
    
    sec_length = floor(length(clean)/NUM_BINS);
    
    for i = 1:NUM_BINS
        curr_sum = 0;
        curr_index = 1;
        
        while curr_sum < target && curr_index < length(impulse_response)
            curr_sum = curr_sum + clean(curr_index);
            curr_index = curr_index + 1;
        end
        
        t_bins(i) = t(curr_index);
        
        d_bins(i) = mean(clean((i-1)*sec_length + 1:i*sec_length));
        target = target + section;
    end
end