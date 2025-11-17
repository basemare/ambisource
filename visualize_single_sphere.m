function visualize_single_sphere(varargin)
% VISUALIZE_SINGLE_SPHERE
%
% Create an equirectangular (360x180 deg) point plot from a directions.json
% file produced by detect_single_sphere.
%
% Input:
%   directions.json
%
% Output:
%   ./directions.png
%
% Example:
%   ambisource visualize single sphere examples/directions.json
%

    if nargin == 0
        print_visualize_single_sphere_help();
        return;
    end

    json_file = varargin{1};
    if ~exist(json_file, "file")
        error('JSON file not found: %s', json_file);
    end

    txt  = fileread(json_file);
    data = jsondecode(txt);

    if ~isfield(data, "azimuth") || ~isfield(data, "elevation")
        error('JSON must contain azimuth and elevation fields.');
    end

    az = data.azimuth(:);
    el = data.elevation(:);

    if numel(az) ~= numel(el)
        error('azimuth and elevation must have same length.');
    end

    az = mod(az, 360);   % force 0…360°

    N = numel(az);
    outfile = fullfile(".", "directions.png");

    % ============================================================
    % Create a equirectangular figure
    % ============================================================
    fig_w = 1200;   % width in pixels
    fig_h = 600;    % height (width/2)
    fig = figure("Visible","off","Color","w", ...
                 "Position",[100 100 fig_w fig_h]);

    ax = axes(fig);
    hold(ax, "on");
    ax.XLim = [0 360];
    ax.YLim = [-90  90];

    axis(ax, 'equal');
    pbaspect(ax, [2 1 1]);       % width : height = 2:1
    axis(ax, 'tight');

    % grid lines
    for e = -90:30:90
        plot(ax, [0 360], [e e], '--', 'Color',[0.8 0.8 0.8]);
    end
    for a = 0:30:360
        plot(ax, [a a], [-90 90], '--', 'Color',[0.8 0.8 0.8]);
    end

    % color by frame index
    cmap = parula(N);

    % scatter points only
    scatter(ax, az, el, 12, cmap, 'filled');

    % start/end markers
    scatter(ax, az(1), el(1), 60, 'g', 'filled', 'MarkerEdgeColor','k');
    scatter(ax, az(end), el(end), 60, 'r', 'filled', 'MarkerEdgeColor','k');

    xlabel(ax, 'Azimuth (deg)');
    ylabel(ax, 'Elevation (deg)');
    title(ax, 'Dominant Source Direction – Equirectangular Projection');

    exportgraphics(fig, outfile, 'Resolution', 200);
    close(fig);

    fprintf('Direction visualization saved: %s\n', outfile);
end


% =====================================================================
% HELP (from top comments)
% =====================================================================
function print_visualize_single_sphere_help()
    txt = help('visualize_single_sphere');
    fprintf('%s\n', txt);
end
