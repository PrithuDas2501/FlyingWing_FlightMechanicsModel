Number_of_sections = 33;
RPM = 2000:500:5000;
%%
RPM_Data = zeros(7,33,15);
for rpm = 1:7
    fid = fopen("BIOMT1WithTipProp_DegenGeom.groups", 'r+');
    n = num2str(RPM(rpm)*2*pi/60);
    for l = 1:33
        line = fgetl(fid);
    end
    
    fprintf(fid, ['Omega = ' n '  ']);
    fclose(fid);

    system('C:\Users\sudip\OneDrive\Documents\OpenVSP-3.36.0-win64\vspaero.exe -omp 4 -qrotor BIOMT1WithTipProp_DegenGeom')
    
    fid = fopen("BIOMT1WithTipProp_DegenGeom.lod", 'r');
    for l = 1:19
        line = fgetl(fid);
    end
    %%
    data= zeros(Number_of_sections,15);
    %%
    for i = 1:Number_of_sections
        line = fgetl(fid);
        c = 19;
        for j = 1:15
            if double(line(c-7)) == 45
                data(i,j) = -1*str2double(line(c-6:c));
            else
                data(i,j) = str2double(line(c-6:c));
            end
            c = c +10;
        end
    end
    fclose(fid);

    RPM_Data(rpm,:,:) = data;
end