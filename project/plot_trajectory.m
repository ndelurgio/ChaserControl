close all

figure(1)
hold on;
scatter(rtx(1:k*ovsf+1),rty(1:k*ovsf+1))
scatter(x_hist(2,:),x_hist(3,:));
legend("Target","Chaser")
title("Ground Trajectory")
xlabel("X")
ylabel("Y")
axis equal