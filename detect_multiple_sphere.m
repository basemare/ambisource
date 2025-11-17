function detect_multiple_sphere(varargin)
% DETECT_MULTIPLE_SPHERE
%
% Multi-source detection on one FOA ambisonics sphere.
% Not implemented yet – this script currently only prints help.
%
% Intended behavior:
%   - Similar to detect_single_sphere script.
%   - Instead of detecting a single global maximum, the algorithm
%     will search for multiple local maxima on the spherical energy map.
%   - Each local maximum corresponds to a potential sound source.
%
% Usage (CLI dispatcher):
%   ambisource detect multiple sphere
%
% Usage (direct):
%   detect_multiple_sphere   % prints this help

    % Always show help (feature not implemented yet)
    print_detect_multiple_sphere_help();
end


% ============================================================
% HELP WRAPPER
% ============================================================
function print_detect_multiple_sphere_help()
    txt = help('detect_multiple_sphere');
    fprintf('%s\n', txt);
end

