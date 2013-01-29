% Records geodetic position from GPS devices into files

% variables
DEBUG=1;
record=1;

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

% file names
files(ublox1)={sprintf('data/%s_ublox1_geodetic',datestr(now,'yyyy.mm.dd-HHMMSS'))};
files(ublox1)={sprintf('data/%s_ublox2_geodetic',datestr(now,'yyyy.mm.dd-HHMMSS'))};

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


%% Read GPS data
% Dump messages
% try
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
            end
            % NAV-POSLLH, just want lat, lon data
            if (out2{4} == POSLLH_MSG)
                parsed = gps_parseMessage_ubx(out2);

                if DEBUG
                    disp(sprintf('%s - NAV-POSLLH (%.0f)\n\tLat: %.2f\n\tLon: %.2f\n\thMSL: %.2f\n',names{ublox2},fixes{ublox2},parsed(3),parsed(2),parsed(5)));
                end
            end
            
        end
        
    end
% catch err
%     % Do nothing
%     disp('Failed recording GPS data:');
%     disp(err.message);
% end

%% Clean up
delete(instrfindall)
clear ports portnums names;

% Done

