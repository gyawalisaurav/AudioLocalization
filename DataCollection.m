NUM_SAMPLES = 2;
room_name = input('Enter Room Name:', 's');
room_name = [room_name '.mat'];
room_samples = [];

for i = 1:NUM_SAMPLES
    data = [];
    [data.t, data.ir, data.z] = GetRIR();
    room_samples = [room_samples, data];
end

save(room_name, 'room_samples');