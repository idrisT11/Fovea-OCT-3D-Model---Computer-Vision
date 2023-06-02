function invAI = snakeDeformMatrix(N, alpha,beta,gamma)



%% Pour un contour à extrémités fixes

motif = [beta -alpha-4*beta 2*alpha+6*beta -alpha-4*beta beta];
motif1 = [beta -2*beta beta];
motif2 = [-alpha-2*beta 2*alpha+5*beta -alpha-4*beta beta];

% motif1 = [0 -4*beta-alpha beta];
% motif2 = [-3*beta-alpha 2*alpha+6*beta -alpha-4*beta beta];

A = zeros(N,N);
A(1,1:3) = motif1;
A(2,1:4) = motif2;
A(3,1:5) = motif;
for i=4:N-3
    A(i,:) = [zeros(1,i-3) motif zeros(1,N-i-2)];  %(1,N-5-(i-3))
end
A(N-2,:) = [zeros(1,N-5) motif];
A(N-1,:) = [zeros(1,N-4) fliplr(motif2)];
A(N,:) = [zeros(1,N-3) fliplr(motif1)];


invAI = inv(A + gamma * diag(ones(1,N)));