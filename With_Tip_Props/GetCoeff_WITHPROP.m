Vf_values = [21.5*0.9 21.5 21.5*1.1];
alpha_values = 2:2:6;
beta_values = -2:2:2;
right_rpm_values = linspace(3000,3600,3);
left_rpm_values = linspace(3000,3600,3);
elevator_values = -2:2:2;
Inneron_Values = -2:2:2;
Outeron_Values = -2:2:2;
counter = 0;
DATA_WITH_PROP = zeros(3,3,3,3,3,3,3,3,12,11);
for v = 1:3
    for alpha =  1:3
        for beta = 1:3
            for rrpm = 1:3
                for lrpm = 1:3
                    for elevator = 1:3
                        for inneron = 1:3
                            for outeron = 1:3
      %%                  
                                fid = fopen("BIOMT1WithTipProp_DegenGeom.vspaero", 'r+');
                                        
                                for l = 1:7
                                    line = fgetl(fid);
                                end
                
                                a = num2str(alpha_values(alpha));
                                b = num2str(beta_values(beta));
                                c = num2str(right_rpm_values(rrpm)*2*pi/60);
                                d = num2str(left_rpm_values(lrpm)*2*pi/60);
                                e = num2str(elevator_values(elevator));
                                f = num2str(Inneron_Values(inneron));
                                g = num2str(Outeron_Values(outeron));
                                h = num2str(Vf_values(v));
                
                                fprintf(fid, ['AoA =', a, '.00000']);
                                line = fgetl(fid);
                                l = l+1;
                                fprintf(fid, ['Beta =', b, '.00000']);
                                line = fgetl(fid);
                                l = l+1;
                                fprintf(fid, ['Vinf =', h, '00000']);
                                for l = 10:22
                                    line = fgetl(fid);
                                end
                                if elevator_values(elevator)<0
                                    fprintf(fid, e);
                                else
                                    fprintf(fid, [e,' ']);
                                end
                                line = fgetl(fid);
                                l = l+1;
            
                                for l = 23:25
                                    line = fgetl(fid);
                                end
                                if Outeron_Values(outeron)<0
                                    fprintf(fid, g);
                                else
                                    fprintf(fid, [g,' ']);
                                end
                                line = fgetl(fid);
                                l = l+1;
            
                                for l = 27:29
                                    line = fgetl(fid);
                                end
                                if Inneron_Values(inneron)<0
                                    fprintf(fid, f);
                                else
                                    fprintf(fid, [f,' ']);
                                end
                                line = fgetl(fid);
                                l = l+1;
            
                                fclose(fid);
                
                                fid = fopen("BIOMT1WithTipProp_DegenGeom.groups", 'r+');
                                for l = 1:33
                                    line = fgetl(fid);
                                end
                                
                                fprintf(fid, ['Omega = ' c '  ']);
                                line = fgetl(fid);
                                l=l+1;
                                for l = 34:52
                                    line = fgetl(fid);
                                end
                                fprintf(fid, ['Omega = -' d '  ']);
                                
                                fclose(fid);
                                
                                
                                system('C:\Users\sudip\OneDrive\Documents\OpenVSP-3.36.0-win64\vspaero.exe -omp 8 -qrotor -stab BIOMT1WithTipProp_DegenGeom');
                                %pause(1)
                
                                fid = fopen('BIOMT1WithTipProp_DegenGeom.stab', 'r');
                                line = fgetl(fid);
                                while length(line)<2
                                    fclose(fid);
                                    disp('GOING INTO SAFETY LOOP');
                                    pause(3);
                                    system('C:\Users\sudip\OneDrive\Documents\OpenVSP-3.36.0-win64\vspaero.exe -omp 8 -qrotor -stab BIOMT1WithTipProp_DegenGeom');
                                    fid = fopen('BIOMT1WithTipProp_DegenGeom.stab', 'r');
                                    line = fgetl(fid);
                                end
                                desired_line = 40; %See the .stab file
                                for i = 2:desired_line-1
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
                                DATA_WITH_PROP(v,alpha,beta,rrpm,lrpm,elevator,inneron,outeron,:,:) = data;
                            end
                        end
                    end
                    
                end
            end
        end
    end
end