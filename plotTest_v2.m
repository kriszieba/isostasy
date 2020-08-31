% Copyright Nestor Cardozo 2009, modified by Krzysztof Jan Zieba 2015

% plot deflections produced by test7.m

% number of points in x and y
pointsx = 251;
pointsy = 251;
% grid size in kilometers
delta = 10.0;

XG=zeros(pointsy,pointsx);
YG=zeros(pointsy,pointsx);
WG=zeros(pointsy,pointsx);

deflection = load('deflection.txt');

count = 1;
for i=1:pointsy
    for j=1:pointsx
        XG(i,j) = (j-1)*delta-250;
        YG(i,j) = (i-1)*delta-250;
        WG(i,j) = deflection(count);
        count = count + 1;
    end
end

v = [-2000:100:2000];
figure('Name','Downward displacement in meters','NumberTitle','off');
[cs,h] = contour(XG,YG,WG,v);
clabel(cs,h);
axis equal;
axis([0 2000 0 2000]);
grid on;
xlabel('km');
ylabel('km');
%% changing from a local coordinate system to utms. Values needed to be taken from input_to_flex_modelling2
min_lat = 7.476830307763000e+06; % for ice model: 7.3551e+03; for sediment 7476.830307763000
min_lon = -2.565479409000000e+03; % for ice model: -4.2682e+02; for sediment -2.565479409000000

min_lat_km = min_lat/1000;
min_lon_km = min_lon/1000;
 
utm_lat = (YG + min_lat_km)*1000;
utm_long = (XG + min_lon_km)*1000;
utm_WG = ceil(WG); %rounded values and negative

%%
figure(33)
hold on
%geoshow(utm_lat, utm_long, utm_WG)
coastline = load('coastline.dat');
plot(coastline(:,2),coastline(:,1))
contour(utm_lat, utm_long,utm_WG)
%%

figure(66)
struct = load('struct.dat');
line(struct(:,1),struct(:,2))




%%

m_size = size(utm_lat);
output_map = zeros(m_size(1,1)*m_size(1,2),3);

for a = 1:m_size(1,1)
    for b = 1:m_size(1,2)
    output_map(b+(a-1)*m_size(1,2),1) = utm_long(b,a);
    output_map(b+(a-1)*m_size(1,2),2) = utm_lat(b,a);
    output_map(b+(a-1)*m_size(1,2),3) = utm_WG(b,a);
    end
end

dlmwrite('deflection_map.txt',output_map,'\t')
%% 
% min_lat = 7476.830307763000; % for ice model: 7.3551e+03; 7.476830307763000e+06
% min_long = -2.565479409000000; % for ice model: -4.2682e+02; -2.565479409000000e+03
% 
% utm_lat = (YG + min_lat)*1000;
% utm_long = (XG + min_long)*1000;
% utm_ZGL = ceil(ZGL*1000); %rounded values and negative
% 
% m_size = size(utm_lat);
% 
% output_map = zeros(m_size(1,1)*m_size(1,2),3);
% 
% for a = 1:m_size(1,1)
%     for b = 1:m_size(1,2)
%     output_map(b+(a-1)*m_size(1,2),1) = utm_long(b,a);
%     output_map(b+(a-1)*m_size(1,2),2) = utm_lat(b,a);
%     output_map(b+(a-1)*m_size(1,2),3) = utm_ZGL(b,a);
%     end
% end
% 
% dlmwrite('load_map.txt',output_map,'\t')


%%

%trimming utm_lat, utm_long, new_WG matrices outside W boundary
% w_lim = min_long * 1000;
% a = 1;
% 
% while a <= m_size(1,2)
% if utm_long(1,a) < w_lim
%     utm_long(:,a) = [];
%     utm_lat(:,a) = [];
%     utm_WG(:,a) = [];
%     m_size = size(utm_long);
% else
%     a=a+1;
%     
% end
% end

% n_lim = 8900000;
% 
% a = 1;
% while a <= m_size(1,1)
% if utm_lat(a,1) > n_lim
%     utm_lat(a,:) = [];
%     utm_long(a,:) = [];
%     utm_WG(a,:) = [];
%     m_size = size(utm_long);
% else
%     a=a+1;
%     
% end
% end

figure(22)
contour(utm_long,utm_lat,utm_WG);
axis equal;
grid on;

%%

% changing from utm to lat long
mercator = 21; %21
lcm = mercator *0.0174532925;
zone = 34;

r_lat = zeros(m_size);
r_long = zeros(m_size);


for a = 1:m_size(1,1)
    for b = 1:m_size(1,2)
    [r_lat(a,b),r_long(a,b)]=utm2ell(utm_lat(a,b),utm_long(a,b),zone,lcm);
    %[r_lat(a,b),r_long(a,b)]=utm2ell(utm_lat(a,b),utm_long(a,b),zone,lcm);
    end
end

% changing from rad to deg
lat = r_lat * 57.2957795;
long = r_long * 57.2957795;


latlim = [70 77]; %limits for displaying AOI [70 77]
lonlim = [0 45];


formatspec = '%f%f%f%f%f%s%s';
wells = readtable('wells.txt', 'Delimiter', '\t', 'Format', formatspec);
well_data = table2array(wells(:,1:5));
well_names = table2array(wells(:,6:7));

% loading and transforming cultural data
coastline = load('coastline.dat');
struct = load('struct.dat');
r_coastline=zeros(size(coastline));
r_struct=zeros(size(struct));

for a = 1:size(coastline,1)
    [r_coastline(a,1),r_coastline(a,2)]=utm2ell(coastline(a,2),coastline(a,1),zone,lcm);
end

for a = 1:size(struct,1)
    [r_struct(a,1),r_struct(a,2)]=utm2ell(struct(a,2),struct(a,1),zone,lcm);
end

r_coastline(:,1) = r_coastline(:,1) * 57.2957795;
r_coastline(:,2) = r_coastline(:,2) * 57.2957795;

r_struct(:,1) = r_struct(:,1) * 57.2957795;
r_struct(:,2) = r_struct(:,2) * 57.2957795;

figure(3)
worldmap(latlim, lonlim)
geoshow(lat, long, utm_WG, 'DisplayType','texturemap')
title('Seabed subsidence due to 1.5 - 0.7 Ma sediment redistribution [m]')

%used for ice sub projection
% cmapsea  = [1 0 0;  1 1 1]; % used for ice loading
% demcmap(-100:25:1300,100,cmapsea,parula)% used for ice loading
% colorbar('Ticks',[-100:100:1300]) % used for ice loading

%demcmap(utm_WG,300,parula,jet)
colorbar

%contourcmap('jet',[-2000:100:2000], 'colorbar','on')

% linem([72;73.25],[18.333;18.333],400, 'k')
% linem([72;73.25],[21.16;21.16],400, 'k')
% linem([72;72],[18.333;21.16],400, 'k')
% linem([73.25;73.25],[18.333;21.16],400,'k')

%plotm(well_data(:,2),well_data(:,1), 'Linestyle', 'none', 'Marker', 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
%textm(well_data(:,2),well_data(:,1),well_names(:,2))
linem(r_struct(:,1),r_struct(:,2), 'k')
linem(r_coastline(:,1),r_coastline(:,2), 'w')

% tilt map in degrees

[ASPECT, SLOPE, gradN, gradE] = gradientm(lat, long, utm_WG);

figure(4)
worldmap(latlim, lonlim)
geoshow(lat, long, SLOPE, 'DisplayType','texturemap')
title('Tilt due to ice loading [deg]')
demcmap(0:0.001:1,100,jet,parula)
colorbar

linem([72;73.25],[18.333;18.333],400, 'k')
linem([72;73.25],[21.16;21.16],400, 'k')
linem([72;72],[18.333;21.16],400, 'k')
linem([73.25;73.25],[18.333;21.16],400,'k')


plotm(well_data(:,2),well_data(:,1), 'Linestyle', 'none', 'Marker', 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
textm(well_data(:,2),well_data(:,1),well_names(:,2))
linem(r_struct(:,1),r_struct(:,2), 'k')
linem(r_coastline(:,1),r_coastline(:,2), 'w')

% tilt map in m/km
rSLOPE = degtorad(SLOPE);
mSLOPE = tan(rSLOPE) * 1000;

% figure(5)
% worldmap(latlim, lonlim)
% geoshow(lat, long, mSLOPE, 'DisplayType','texturemap')
% title('Tilt due to ice loading [m/km]')
% demcmap(0:0.1:10,100,cmapsea,parula)
% colorbar

% loading coastline and structural elements


% transforming utm to rad
r_coastline=zeros(size(coastline));
r_struct=zeros(size(struct));

for a = 1:size(coastline,1)
    [r_coastline(a,1),r_coastline(a,2)]=utm2ell(coastline(a,2),coastline(a,1),zone,lcm);
end

for a = 1:size(struct,1)
    [r_struct(a,1),r_struct(a,2)]=utm2ell(struct(a,2),struct(a,1),zone,lcm);
end

%transforming from rad to deg
r_coastline(:,1) = r_coastline(:,1) * 57.2957795;
r_coastline(:,2) = r_coastline(:,2) * 57.2957795;

r_struct(:,1) = r_struct(:,1) * 57.2957795;
r_struct(:,2) = r_struct(:,2) * 57.2957795;

figure(6)
worldmap(latlim, lonlim)
geoshow(lat, long, mSLOPE, 'DisplayType','texturemap')
title('Tilting due to 1.5 - 0.7 Ma sediment redistribution [m/km]')
demcmap(mSLOPE,100,jet,parula)
colorbar
linem(r_coastline(:,1),r_coastline(:,2), 'w')
linem(r_struct(:,1),r_struct(:,2), 'k')