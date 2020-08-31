% Copyright Nestor Cardozo 2009

% plot deflections produced by test7.m

% number of points in x and y
pointsx = 251;
pointsy = 251;
% grid size in kilometers
delta = 10.0;

XG=zeros(pointsy,pointsx);
YG=zeros(pointsy,pointsx);
WG=zeros(pointsy,pointsx);

load deflection.txt;

count = 1;
for i=1:pointsy
    for j=1:pointsx
        XG(i,j) = (j-1)*delta-250;
        YG(i,j) = (i-1)*delta-250;
        WG(i,j) = deflection(count);
        count = count + 1;
    end
end

figure('Name','Downward displacement in meters','NumberTitle','off');
[cs,h] = contour(XG,YG,WG);
clabel(cs,h);
axis equal;
axis([0 2000 0 2000]);
grid on;
xlabel('km');
ylabel('km');
%% changing from a local coordinate system to cartesian (only Y values)
% reading cartesian Y coordinate for SW-most corner. Should be the same as
% 'max' in the 'input_to_flex_modelling' file
max = 2569.3;
YG_reg = YG*(-1) + max;

% i don't know it this is a good way...
% [THETA,RHO] = cart2pol(XG,YG_reg);
% deg=rad2deg(THETA);

%uses average radius
Z = zeros(251,251);
Z = Z+5.8000e+06;

[lat,lon,h]=xyz2ell(XG,YG_reg,Z);

deg = rad2deg(lat);

%%
worldmap%(latlim, lonlim)
geoshow(YG_reg, XG, WG, 'DisplayType','texturemap')
demcmap(WG)
daspectm('m',1)
colorbar

