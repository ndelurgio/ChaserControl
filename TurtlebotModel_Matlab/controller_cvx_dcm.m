function u = controller_cvx_dcm(x_chaser_k,x_target_kpN,N,dt_cvx)

% Direction Cosine Matrix
C_k = [cos(x_chaser_k(1)), sin(x_chaser_k(1))
      -sin(x_chaser_k(1)), cos(x_chaser_k(1))];

% Matrix to elimate use of theta in cost function
Q = [0,0,0,0;
     0,0,0,0;
     0,0,1,0;
     0,0,0,1];
%P = 3;
%construct DCM state vector
x_chaser_k = [C_k(1,1);C_k(1,2);x_chaser_k(2);x_chaser_k(3)];
x_target_kpN = [cos(x_target_kpN(1));sin(x_target_kpN(1));x_target_kpN(2);x_target_kpN(3)];

cvx_begin
    variable u_mat(2,N) 
    variable x_chaser(4,N)

    minimize( (x_target_kpN - x_chaser(:,end))' * Q * (x_target_kpN - x_chaser(:,end)) )

    subject to
        x_chaser(:,1) == x_chaser_k
        for i = 1:N-1
           Bi = [-x_chaser(2,i), 0;
                 x_chaser(1,i), 0;
                 0, x_chaser(1,i);
                 0, x_chaser(2,i)];
           x_chaser(:,i+1) == dt_cvx*Bi*u_mat(:,i)
        end
        -pi/2 <= u_mat(1,:) <= pi/2
        0 <= u_mat(2,:) <= 0.1

cvx_end

u = u_mat(:,1);

end