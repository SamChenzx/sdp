function [arr] = gps_parseMessage_ubx(msg)
% [str] = gps_readMessage_ubx(msg)
%
% Parses a UBX GPS message and returns the data. Currently only
% works with Navigational Geodetic Position messages (1,2).
%
% Arguments:
%   msg: a raw UBX GPS message
%
% Returns:
%   an array containing each field
%
% Messages:
%   NAV-POSLLH (0x01 0x02)
%   --
%   iTow: GPS millisecond time of week (ms)
%   lon: longitude (deg)
%   lat: latitude (deg)
%   height: height above ellipsoid (mm)
%   hMSL: height above mean sea level (mm)
%   hAcc: horizontal accuracy estimate (mm)
%   vAcc: vertical accuracy estimate (mm)
%

DEBUG = 1;
PAYLOAD_START_INDEX = 6;
pS = PAYLOAD_START_INDEX; % shorthand

if nargin < 1
    error('Missing argument ''msg''')
elseif isstr(msg{1})
    error('Expected ''msg'' as integers, but got strings.');
end

id = [msg{3} msg{4}];
arr = [];

% Navigation messages
if id(1) == 1
    %  NAV-POSLLH (0x01 0x02) - Geodetic Position Solution Message
    if id(2) == 2
        % iTow (ms) uint32_t - GPS Millisecond Time of Week
        arr(1) = typecast(uint32(bitconcat(fi(msg{pS + 3},0,8), fi(msg{pS + 2},0,8), fi(msg{pS + 1},0,8), fi(msg{pS},0,8))),'uint32');
        % lon (deg) int32_t - Longitude scaled 1e-7
        arr(2) = typecast(uint32(bitconcat(fi(msg{pS + 7},0,8), fi(msg{pS + 6},0,8), fi(msg{pS + 5},0,8), fi(msg{pS + 4},0,8))),'int32');
        % lat (deg) int32_t - Latitude scaled 1e-7
        arr(3) = typecast(uint32(bitconcat(fi(msg{pS + 11},0,8), fi(msg{pS + 10},0,8), fi(msg{pS + 9},0,8), fi(msg{pS + 8},0,8))),'int32');
        % height (mm) int32_t - Height above Ellipsoid
        arr(4) = typecast(uint32(bitconcat(fi(msg{pS + 15},0,8), fi(msg{pS + 14},0,8), fi(msg{pS + 13},0,8), fi(msg{pS + 12},0,8))),'int32');
        % hMSL (mm) int32_t - Height above Mean Sea Level
        arr(5) = typecast(uint32(bitconcat(fi(msg{pS + 19},0,8), fi(msg{pS + 18},0,8), fi(msg{pS + 17},0,8), fi(msg{pS + 16},0,8))),'int32');
        % hAcc (mm) uint32_t - Horizontal Accuracy Estimate
        arr(6) = typecast(uint32(bitconcat(fi(msg{pS + 23},0,8), fi(msg{pS + 22},0,8), fi(msg{pS + 21},0,8), fi(msg{pS + 20},0,8))),'uint32');
        % vAcc (mm) uint32_t - Vertical Accuracy Estimate
        arr(7) = typecast(uint32(bitconcat(fi(msg{pS + 27},0,8), fi(msg{pS + 26},0,8), fi(msg{pS + 25},0,8), fi(msg{pS + 24},0,8))),'uint32');
    elseif id(2) == 3
        % iTow (ms) uint32_t - GPS Millisecond Time of Week
        arr(1) = typecast(uint32(bitconcat(fi(msg{pS + 3},0,8), fi(msg{pS + 2},0,8), fi(msg{pS + 1},0,8), fi(msg{pS},0,8))),'uint32');
        % gpsFix (enum) uint8_t - GPSfix Type
        arr(2) = msg{pS + 4};
        % flags (bitfield) uint8_t - Navigation Status Flags
        arr(3) = msg{pS + 5};
        % diffStat (bitfield) int8_t - Differential Status
        arr(4) = msg{pS + 6};
        % res  - Reserved
        arr(5) = msg{pS + 7};
        % ttff (ms) uint32_t - Time to first fix (millisecond time tag)
        arr(6) = typecast(uint32(bitconcat(fi(msg{pS + 11},0,8), fi(msg{pS + 10},0,8), fi(msg{pS + 9},0,8), fi(msg{pS + 8},0,8))),'uint32');
        % msss (ms) uint32_t - Milliseconds since Startup / Reset
        arr(7) = typecast(uint32(bitconcat(fi(msg{pS + 15},0,8), fi(msg{pS + 14},0,8), fi(msg{pS + 13},0,8), fi(msg{pS + 12},0,8))),'uint32');
    else
        error(sprintf('Navigation message 0x%X not implemented.', id(2)));
    end
else
    error(sprintf('Message ID 0x%X 0x%X not implemented.',msg(3),msg(4)));
end

end % function

