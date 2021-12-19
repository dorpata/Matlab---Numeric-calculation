M = 18;
ro = 1 ;             % ro equel 1m
q = [3,1,2,1,3,3,7,7,0,2,0,5,5,5,6,5,3,3]' ;      % vector with out ID
A = eye(M);
delta = (pi*ro)/M;
h_list = [delta, 2*delta, 5*delta, 10*delta, 20*delta, 50*delta];
% (1) for h = (pi*ro)/M, we find A, cal LU and A Status number,and norm A,v,q.
h_1 = h_list(1);                  
for m = [1:M]                          % create matrix A
    for n = [1:M]
        r = sqrt((h_1+ro*sin((m*pi)/M) - ro*sin((n*pi)/M))^2+(ro*cos((m*pi)/M)- ro*cos((n*pi)/M))^2);
        A(m,n) =  1/(4*pi*r);
    end
end       
v = A*q;                               % calculate vector v = A*q
[L,U,P] = lu(A);
k = norm(A)*norm(inv(A));
norm_fro_A = norm(A,'fro');
norm_2_v = norm(v,2);
norm_2_q = norm(q,2);

% (2) Two routines - for cal Ux=y and Ly=b
v_p = P*v;
b = front(L,v_p);                % from (L*b=v)
q_2 = back(U,b);                 % q as requested (U*q=b)
e2 = norm(q-q_2,2)/norm(q,2);    % calculate the error

%(3) same as (2) but this time we add vector measurement error delta(v)
v_3 = v + 10^(-3)*norm(v,2) ;
v_p_3 = P*v_3;
b_3 = front(L,v_p_3);                % from (L*b=v)
q_3 = back(U,b_3);                 % q as requested (U*q=b)
e3 = norm(q-q_3,2)/norm(q,2);    % calculate the error

% (4) same as (2) but this time we add matrix measurement error delta(A)
A_4 = A + norm(A,'fro')*10^(-3);
[L,U,P] = lu(A_4);
v_p = P*v;
b_3 = front(L,v_p);                % from (L*b=v)
q_4 = back(U,b_3);                 % q as requested (U*q=b)
e4 = norm(q-q_4,2)/norm(q,2);      % calculate the error

%(5) we repeat (1)-(4) for various h 
err_2 = zeros(1,6);
err_3 = zeros(1,6);
err_4 = zeros(1,6);
k_vector = zeros(1,6);

for i = 1:6
 %(1):    
    h = h_list(i);                    
    for m = [1:M]                          % create matrix A
        for n = [1:M]
            r = sqrt((h +ro*sin((m*pi)/M) - ro*sin((n*pi)/M))^2+(ro*cos((m*pi)/M)- ro*cos((n*pi)/M))^2);
            A(m,n) =  1/(4*pi*r);
        end
    end 
    v = A*q;                               % calculate vector v = A*q
    [L,U,P] = lu(A);
    k_vector(i) = norm(A)*norm(inv(A))
    norm_fro_A = norm(A,'fro');
    norm_2_v = norm(v,2);
    norm_2_q = norm(q,2);
%(2)
    v_p = P*v;      
    b = front(L,v_p);                % from (L*b=v)
    sel_q2 = back(U,b);                 % q as requested (U*q=b)
    err_2(i) = norm(q-sel_q2,2)/norm(q,2);    % calculate the error
%(3)
    v_3 = v + 10^(-3)*norm(v,2) ;
    v_p_3 = P*v_3;
    b_3 = front(L,v_p_3);                % from (L*b=v)
    sel_q3 = back(U,b_3);                 % q as requested (U*q=b)
    err_3(i) = norm(q-sel_q3,2)/norm(q,2);    % calculate the error
%(4)
    A_4 = A + norm(A,'fro')*10^(-3);
    [L,U,P] = lu(A_4);
    v_p = P*v;
    b_3 = front(L,v_p);                % from (L*b=v)
    sel_q4 = back(U,b_3);                 % q as requested (U*q=b)
    err_4(i) = norm(q-sel_q4,2)/norm(q,2);      % calculate the error
end

% set everything in a plot:
figure
loglog(h_list,err_2,'-o',h_list,err_3,'-o',h_list,err_4,'-o',h_list,k_vector,'-o');
title("Q1 error and state number");
legend('A*q=v','A*q=(v+dv)','(A+dA)*q=v','K(A)');
xlabel('h');
xticks(h_list);
ylabel('Realitive error and K(A)');
grid on



function [y] = front(X,v)
    y = [];
    for i = 1:length(X)
        y(end+1) = v(i)/X(i,i);
        for r = 1:(length(y)-1)
            y(length(y)) = y(length(y))-(y(r)*X(i,r))/X(i,i);
        end
    end    
end

function [x] = back(X,y)
    x = zeros(length(y),1);
    for i = length(X):-1:1
        x(i) = y(i)/X(i,i);
        for j = i+1: length(x)
            x(i) = x(i) - (x(j)*X(i,j))/X(i,i);
        end
    end    
end 

    






  