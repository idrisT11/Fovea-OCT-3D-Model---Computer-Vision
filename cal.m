function res =  cal (im)
m1=min(im(:));
m2=max(im(:));
res = (im-m1)/(m2-m1);
