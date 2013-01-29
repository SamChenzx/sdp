% Records geodetic position from GPS devices into files
close all;
% variables
DEBUG=1;
record=1;
breakkey = 'q';

%% GPS Configuration
% device enumeration
ublox1=1;
ublox2=2;

% device names
clear names;
names(ublox1)={'Ublox-1'};      % A
names(ublox2)={'Ublox-2'};      % B

% close all serial ports
delete(instrfindall)

% com ports (configure these)
clear portnums;
%portnums(ublox1)=1;
portnums(ublox2)=6;
%portnums(ublox1)={'/dev/tty.usbserial-A1012WFD'};
%portnums(ublox2)={'/dev/tty.usbserial-A1012WEE'};

% connect to devices
clear ports;
%ports(ublox1) = {gps_configure_ublox(portnums(ublox1))};
ports(ublox2) = {gps_configure_ublox(portnums(ublox2))};

if DEBUG
    disp(sprintf('Success!\n'));
    disp(sprintf('Recording...'));
end

% Class and Type Flags
NAV_CLASS = 1;
% Message Types
POSLLH_MSG = 2;
STATUS_MSG = 3;
% Fix Types
NO_FIX = 0;

% Device Statuses
clear fixes;
fixes(ublox1) = {NO_FIX};
fixes(ublox2) = {NO_FIX};
everfixed(ublox1) = {0};
everfixed(ublox2) = {0};

% Start a new KML file
filenames(ublox1)={sprintf('%s_ublox1_geodetic',datestr(now,'yyyy.mm.dd-HHMMSS'))};
filenames(ublox2)={sprintf('%s_ublox2_geodetic',datestr(now,'yyyy.mm.dd-HHMMSS'))};
files(ublox1)={sprintf('data/%s',filenames{ublox1})};
files(ublox2)={sprintf('data/%s',filenames{ublox2})};

%k(ublox1) = {kml(filenames(ublox1))};
k = kml(filenames{ublox2});

err = 0;
%% Read GPS data
% Dump messages
try
    while 1
        out2 = gps_readMessage_ubx(ports{ublox2},0);
        if ~iscell(out2)
            continue;
        end
        %------------- NAVIGATION MESSAGES --------------
        if out2{3} == NAV_CLASS
            % NAV-STATUS, fix or not
            if (out2{4} == STATUS_MSG)
                parsed = gps_parseMessage_ubx(out2);
                
                % No lock, so skip
                if parsed(2) == NO_FIX
                    if DEBUG
                        disp(sprintf('%s not fixed.',names{ublox2}));
                    end
                    continue
                end
                
                if DEBUG && fixes{ublox2} == NO_FIX
                	disp(sprintf('%s has a lock.\n',names{ublox2}));
                end
                fixes{ublox2} = parsed(2);
                everfixed{ublox2} = 1;
            end
            % NAV-POSLLH, just want lat, lon data
            if (fixes{ublox2} ~= NO_FIX && out2{4} == POSLLH_MSG)
                parsed = gps_parseMessage_ubx(out2);
                lat = parsed(3)*10^(-7);
                lon = parsed(2)*10^(-7);
                %hmsl = (parsed(5)*10^(-3))*3.28084; % (ft)
                hmsl = (parsed(5)*10^(-3)); % (m)
                
                if DEBUG
                    disp(sprintf('%s - NAV-POSLLH (%.0f)\n\tLat: %.2f\n\tLon: %.2f\n\thMSL: %.2f\n',names{ublox2},fixes{ublox2},lat,lon,hmsl));
                end
                
                %k{ublox2}.plot3(lon,lat,hmsl)
                k.plot3(lon,lat,hmsl);
            end
            
        end
        pause(0.01);
        % Check for key press
        if strcmp(get(gcf,'currentkey'),breakkey)
            disp(sprintf('Stopped recording.\n'));
            break
        end
    end % while
catch err
    % Do nothing
end

%% Clean up
% Save the results
if everfixed{ublox2}
    disp(sprintf('Saving %s.kml...',files{ublox2}));
    k.save(sprintf('%s.kml',files{ublox2}));
else
    disp('Skipping kml file since never fixed.');
end

closeallSerialPorts;
clear k;


if (strcmp(class(err), 'MException'))
    disp('Failed recording GPS data:');
    rethrow(err);
end

% Done

