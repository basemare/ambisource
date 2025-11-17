function detect_single_space(varargin)
% DETECT_SINGLE_SPACE
%
% Single-source localization in space using two FOA ambisonics recorders.
% Not implemented yet – this script currently only prints help.
%
% Intended behavior:
%   - Using simultaneous recordings from two FOA recorders placed at a known distance from each other.
%   - For each recorder, estimate the dominant direction (main beam).
%   - Compute the intersection of these beams in 3D space.
%   - Output the estimated 3D position of a single dominant source.
%
% Usage (CLI dispatcher):
%   ambisource detect single space
%
% Usage (direct):
%   detect_single_space   % prints this help

    % Always show help (feature not implemented yet)
    print_detect_single_space_help();
end


% ============================================================
% HELP WRAPPER
% ============================================================
function print_detect_single_space_help()
    txt = help('detect_single_space');
    fprintf('%s\n', txt);
end

