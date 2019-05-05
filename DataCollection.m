NUM_SAMPLES = 50;
room_name = input('Enter Room Name:', 's');
room_name = [room_name '.mat'];
room_samples = [];

for i = 1:NUM_SAMPLES
    data = [];
    data.pose_x = input('Enter Pose x coordinate:', 's');
    data.pose_y = input('Enter Pose y coordinate:', 's');
    [data.t, data.ir, data.z] = GetRIR();
    room_samples = [room_samples, data];
end

save(room_name, 'room_samples');