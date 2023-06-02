
% -------------------------------------------------------------------------
% GVF Snake - Classical (Kass)
%
%   I           : source image in gray-level
%   [px,py]     : external forces  (GVF)
%   x0,y0       : contour initialization
%   alpha       : elasticity parameter 
%   beta        : rigidity parameter
%   gamma       : viscosity parameter 
%   kappa       : external force weight 
%   nbiter      : maximal number of iterations
%   stepIter    : number of iterations before resampling
%   maxChange   : stopping criterion
% -------------------------------------------------------------------------

function [x,y] = GVFSnakeClose(I,px,py,x0,y0, alpha,beta,gamma,kappa,nbiter,stepIter,maxChange, fid)



if exist('fid') && ~isempty(fid),
    figure(fid)
    imshow(I); hold on; plot(x0,y0,'r');
    AffichMode = 1;
else
    AffichMode = 0;
end

    
% Interpolation
[x,y] =  curveResamplingClose(x0(:),y0(:),1);
    
    
% % Create video
% v = VideoWriter('GVFSnake.avi','Uncompressed AVI');
% open(v);

if AffichMode
    hold off; imshow(I);hold on; plot(x,y,'r'); title 'Initial snake'
%     cdata = print(fid,'-RGBImage');writeVideo(v,cdata);
%     plot(x(1),y(1),'g.');
    pause(0.1); 
end
    
i = 0;
stop = 0;


    
    
while i<nbiter && ~stop

    % Store the last position
    x_old = x; y_old = y;         

    % Compute the matrix applied to deform the snake
    N =length(x);
    invAI = snakeDeformMatrixClose(N, alpha,beta,gamma);

        
    % Deform for ITER iterations without resampling
    for count = 1:stepIter,

       vfx = interp2(px,x,y,'linear',0);
       vfy = interp2(py,x,y,'linear',0);
       vfx(1:2) = 0;vfx(N-1:N) = 0; vfy(1:2) = 0;vfy(N-1:N) = 0;

       % deform snake
       x = invAI * (gamma* x + kappa*vfx);
       y = invAI * (gamma* y + kappa*vfy);
    end

       
    % Check the displacements     
    change = max(abs(x-x_old) + abs(y-y_old) );
    if change < maxChange
        stop = 1;
    end
        
    % Resample    
    [x,y] = curveResamplingClose(x,y,1);
    
    % Display
    i = i+stepIter;
    if AffichMode
        hold off; imshow(I);hold on; plot(x,y,'r'); title (['Iteration ' num2str(i)])
%         cdata = print(fid,'-RGBImage');writeVideo(v,cdata);
%         plot(x(1),y(1),'g.');
        pause(0.1);
    end
   

end

% close(v); 