fid = fopen('BIOMT1WithTipProp_DegenGeom.stab', 'r');
desired_line = 40; %See the .stab file
for i = 1:desired_line-1
    line = fgetl(fid);
end

data = zeros(12,11);

for i = 1:12
    line = fgetl(fid);
    c = 19;
    for j = 1:11
        if double(line(c-9)) == 45
            data(i,j) = -1*str2double(line(c-8:c));
        else
            data(i,j) = str2double(line(c-8:c));
        end
        c = c +13;
    end
end
fclose(fid);
counter = counter + 1;
data