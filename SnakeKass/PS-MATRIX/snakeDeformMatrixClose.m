function invAI = snakeDeformMatrixClose(N, alpha,beta,gamma)



%% Pour un contour à extrémités fixes

motif = [beta -alpha-4*beta 2*alpha+6*beta -alpha-4*beta beta];
motif1 = [2*alpha+6*beta -alpha-4*beta beta];
motif2 = [-alpha-4*beta 2*alpha+6*beta -alpha-4*beta beta];

% motif1 = [0 -4*beta-alpha beta];
% motif2 = [-3*beta-alpha 2*alpha+6*beta -alpha-4*beta beta];

A = zeros(N,N);

A(1,1:3) = [2*alpha+6*beta -alpha-4*beta beta];
A(1,end-1:end) = [beta -alpha-4*beta];

A(2,1:4) = [-alpha-4*beta 2*alpha+6*beta -alpha-4*beta beta];
A(2,end) = beta;

A(3,1:5) = motif;
for i=4:N-3
    A(i,:) = [zeros(1,i-3) motif zeros(1,N-i-2)];  %(1,N-5-(i-3))
end
A(N-2,:) = [zeros(1,N-5) motif];

A(N-1,1) = beta;
A(N-1,end-3:end) = [beta -alpha-4*beta 2*alpha+6*beta -alpha-4*beta];

A(N,1:2) = [-alpha-4*beta beta];
A(N,end-2:end) = [beta -alpha-4*beta 2*alpha+6*beta];


invAI = inv(A + gamma * diag(ones(1,N)));