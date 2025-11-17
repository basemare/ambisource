function detect_multiple_space(varargin)
% DETECT_MULTIPLE_SPACE
%
% Multi-source detection in space using two FOA ambisonics recorders.
% Not implemented yet – this script currently only prints help.
%
% Intended behavior:
%   - Use multiple local maxima from two FOA recorders.
%   - Form beams from each local maximum on each sphere.
%   - Search for intersections between beams from recorder A and recorder B.
%   - Each intersection candidate corresponds to a potential source in space.
%
% Usage (CLI dispatcher):
%   ambisource detect multiple space
%
% Usage (direct):
%   detect_multiple_space   % prints this help

    % Always show help (feature not implemented yet)
    print_detect_multiple_space_help();
end


% ============================================================
% HELP WRAPPER
% ============================================================
function print_detect_multiple_space_help()
    txt = help('detect_multiple_space');
    fprintf('%s\n', txt);
end

