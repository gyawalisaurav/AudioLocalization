[data, dict] = getDataMatrix();

function [data, dict] = getDataMatrix()
    NUM_SAMPLES = 50;
    [filenames, roomnames] = getFilenames();
    NUM_ROOMS = length(filenames);
  
    comb_a = [];
    comb_b = [];
    comb_r = [];
    comb_sd = [];
    comb_rid = [];
    comb_xs = [];
    comb_ys = [];
    comb_bins = [];
    
    for i = 1:NUM_ROOMS
        load(filenames(i), 'room_samples');
        as = zeros(NUM_SAMPLES, 1);
        bs = zeros(NUM_SAMPLES, 1);
        rs = zeros(NUM_SAMPLES, 1);
        sds = zeros(NUM_SAMPLES, 1);
        rids = zeros(NUM_SAMPLES, 1);
        xs = zeros(NUM_SAMPLES, 1);
        ys = zeros(NUM_SAMPLES, 1);
        bins = zeros(NUM_SAMPLES, 40);
        
        for j = 1:NUM_SAMPLES
            [a, b, r] = getDecayFit(room_samples(j).t, room_samples(j).ir);
            %plot(room_samples(j).t, room_samples(j).ir);
            %xlabel('Time');
            %ylabel('Response');
            z = room_samples(j).z;
            [f,~] = histcounts(abs(z(1:round(length(z)/2))));
            sd = std(f);          
            
            as(j) = a;
            bs(j) = b;
            rs(j) = r;
            sds(j) = sd;
            rids(j) = i;
            
            xs(j) = str2double(room_samples(j).pose_x);
            ys(j) = str2double(room_samples(j).pose_y);
            
            [t_bins, d_bins] = getTimeBins(room_samples(j).t, room_samples(j).ir);
            bins(j, :) = [t_bins, d_bins];
        end
        
        comb_a = [comb_a; as];
        comb_b = [comb_b; bs];
        comb_r = [comb_r; rs];
        comb_sd = [comb_sd; sds];
        comb_rid = [comb_rid; rids];
        comb_xs = [comb_xs; xs];
        comb_ys = [comb_ys; ys];
        comb_bins = [comb_bins; bins];
    end
    
    data = [comb_rid, comb_xs, comb_ys, comb_a, comb_b, comb_r, comb_sd, comb_bins];
    dict = roomnames;
end

function [fnames, rnames] = getFilenames()
    files = dir(fullfile(pwd,'*.mat'));
    num = length(files);
    
    fnames = string(num);
    rnames = string(num);
    for i = 1:length(files)
        fnames(i) = files(i).name;
        rnames(i) = extractBetween(fnames(i), 1, strlength(fnames(i)) -4);
    end
end

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
   % plot(f, t(max_i:tail_start), clean(max_i:tail_start));
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