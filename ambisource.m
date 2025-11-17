function ambisource(cmd, varargin)
% ambisource – Ambisonic sound source detection CLI toolkit.
%
% Start using the toolkit by typing 'ambisource' in your MATLAB command window.
%
% Call any subcommand without arguments to display its help.
%
% Usage:
%   ambisource help
%   ambisource detect
%   ambisource visualize
%
% Detection subcommands:
%   ambisource detect single sphere
%   ambisource detect multiple sphere
%   ambisource detect single space
%   ambisource detect multiple space
%
% Visualization subcommands:
%   ambisource visualize single sphere
%   ambisource visualize multiple sphere
%   ambisource visualize single space
%   ambisource visualize multiple space
%

    if nargin == 0
        print_main_help();
        return;
    end

    switch lower(cmd)

        case {'help','--help','-h'}
            print_main_help();

        case 'detect'
            handle_detect(varargin{:});

        case 'visualize'
            handle_visualize(varargin{:});

        otherwise
            fprintf('ambisource: unknown command "%s"\n', cmd);
            fprintf('Use "ambisource help" to list available commands.\n');
    end
end


% =====================================================================
% DETECT ROUTER
% =====================================================================
function handle_detect(varargin)

    if nargin == 0
        print_detect_general_help();
        return;
    end

    if nargin < 2
        print_detect_general_help();
        return;
    end

    word1 = lower(string(varargin{1}));
    word2 = lower(string(varargin{2}));
    key   = word1 + " " + word2;

    switch key

        case "single sphere"
            if nargin == 2
                help detect_single_sphere;
            else
                detect_single_sphere(varargin{3:end});
            end

        case "multiple sphere"
            if nargin == 2
                help detect_multiple_sphere;
            else
                detect_multiple_sphere(varargin{3:end});
            end

        case "single space"
            if nargin == 2
                help detect_single_space;
            else
                detect_single_space(varargin{3:end});
            end

        case "multiple space"
            if nargin == 2
                help detect_multiple_space;
            else
                detect_multiple_space(varargin{3:end});
            end

        otherwise
            print_detect_general_help();
    end
end


% =====================================================================
% VISUALIZE ROUTER
% =====================================================================
function handle_visualize(varargin)

    if nargin == 0
        print_visualize_general_help();
        return;
    end

    if nargin < 2
        print_visualize_general_help();
        return;
    end

    word1 = lower(string(varargin{1}));
    word2 = lower(string(varargin{2}));
    key   = word1 + " " + word2;

    switch key

        case "single sphere"
            if nargin == 2
                help visualize_single_sphere;
            else
                visualize_single_sphere(varargin{3:end});
            end

        case "multiple sphere"
            if nargin == 2
                help visualize_multiple_sphere;
            else
                visualize_multiple_sphere(varargin{3:end});
            end

        case "single space"
            if nargin == 2
                help visualize_single_space;
            else
                visualize_single_space(varargin{3:end});
            end

        case "multiple space"
            if nargin == 2
                help visualize_multiple_space;
            else
                visualize_multiple_space(varargin{3:end});
            end

        otherwise
            print_visualize_general_help();
    end
end


% =====================================================================
% PRINT MAIN HELP (from top comments)
% =====================================================================
function print_main_help()
    txt = help('ambisource');
    fprintf('%s\n', txt);
end


% =====================================================================
% DETECT GENERAL HELP
% =====================================================================
function print_detect_general_help()

    lines = strsplit(help('ambisource'), '\n');

    fprintf('\nAMBISOURCE / DETECT – Detection tools\n\n');
    fprintf("Subcommands:\n");

    for i = 1:numel(lines)
        L = strtrim(lines{i});
        if startsWith(L, 'ambisource detect ')
            fprintf('  %s\n', L);
        end
    end

    fprintf('\nRun any subcommand without arguments to show its detailed help.\n\n');
end


% =====================================================================
% VISUALIZE GENERAL HELP
% =====================================================================
function print_visualize_general_help()

    lines = strsplit(help('ambisource'), '\n');

    fprintf('\nAMBISOURCE / VISUALIZE – Visualization tools\n\n');
    fprintf("Subcommands:\n");

    for i = 1:numel(lines)
        L = strtrim(lines{i});
        if startsWith(L, 'ambisource visualize ')
            fprintf('  %s\n', L);
        end
    end

    fprintf('\nRun any subcommand without arguments to show its detailed help.\n\n');
end

