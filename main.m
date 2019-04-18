[t, ir] = GetRIR();
plot(t,ir);
[da, db, rt] = getDecayFit(t, ir);

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