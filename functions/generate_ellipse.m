function [x,y] = generate_ellipse(x0,y0,x1,y1)
    
    % constant to convert from pixels to meters
    k = 7.7091e-04;
    
    % compute semi major and semi minor axis from meters to pixels
    a = 0.1/2/k;
    b = 0.05/2/k;
    
    % compute eccentricity
    e = sqrt(a^2 - b^2)/a;
    
    % compute distances between centers
    delta_x = x1-x0;
    delta_y = y1-y0;
    
    % compute inclination of the ellipse
    theta = atan2(delta_y,delta_x);
    
    % fin Center of Mass
    CoM = [(x1+x0)/2, (y1+y0)/2];
    
    % find vertices of the ellipse
    x1 = CoM(1) + a*cos(theta); y1 = CoM(2) + a*sin(theta);
    x2 = CoM(1) - a*cos(theta); y2 = CoM(2) - a*sin(theta);
    
    % compute 100 points of the ellisse
    a = 1/2*sqrt((x2-x1)^2+(y2-y1)^2);
    b = a*sqrt(1-e^2);
    t = linspace(0,2*pi);
    X = a*cos(t);
    Y = b*sin(t);
    w = atan2(y2-y1,x2-x1);
    
    x = (x1+x2)/2 + X*cos(w) - Y*sin(w);
    y = (y1+y2)/2 + X*sin(w) + Y*cos(w);

end

