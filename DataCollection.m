NUM_POINTS = 25;
NUM_REPS = 2;

room_name = input('Enter Room Name:', 's');
room_name = [room_name '.mat'];
room_samples = [];

for i = 1:NUM_POINTS
    data = [];
    data.pose_x = input('Enter Pose x coordinate:', 's');
    data.pose_y = input('Enter Pose y coordinate:', 's');
    
    for j = 1:NUM_REPS
        [data.t, data.ir, data.z] = GetRIR();
        room_samples = [room_samples, data];
    end
    
    disp(i);
end

save(room_name, 'room_samples');