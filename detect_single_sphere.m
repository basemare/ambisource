function detect_single_sphere(varargin)
% DETECT_SINGLE_SPHERE
%
% Direction estimation of the dominant sound source surrounding a recorder
% using First-Order Ambisonics (FOA) signals.
%
% High-pass filter used to remove wind noise.
%
% Input FOA:
%   recording (FOA B-format signal, Nx4) OR path to WAV file
%
% Output:
%   directions.json      – dominant source direction for each frame (json mode)
%   frames/*.png         – full-sphere heatmap (PNG mode)
%
% Usage (direct):
%   detect_single_sphere(ambi_b, fs, outdir)
%   detect_single_sphere(ambi_b, fs, outdir, mode)
%   detect_single_sphere(ambi_b, fs, outdir, mode, <options...>)
%
% Usage (via CLI dispatcher):
%   ambisource detect single sphere ambi_b fs outdir
%   ambisource detect single sphere ambi_b fs outdir mode
%   ambisource detect single sphere ambi_b fs outdir mode <options...>
%
% ----------------------------------------------------------------------
% OPTIONS (override default parameters)
%
%   res=DEG        Angular grid resolution in degrees (PNG resolution). Default: 1
%   hpf=FREQ       High-pass filter cutoff frequency in Hz. Default: 150
%   order=N        High-pass IIR filter order. Default: 4
%   fps=N          Output frame rate (PNG mode). Default: 30
%   colormap=N     turbo() colormap resolution. Default: 256
%   alpha_k=N      Alpha-map contrast parameter. Default: 99
%   framelen=SEC   Frame length in seconds for covariance analysis. Default: 1
%   t0=TIME        Analysis start time (seconds or MM:SS). Default: 0
%   t1=TIME        Analysis end time (seconds or MM:SS). Default: full length
%
% ----------------------------------------------------------------------
%
% Examples:
%   % JSON mode, full range:
%   ambisource detect single sphere examples/example_rec.wav 48000 out json res=1 fps=30
%
%   % PNG mode, 1m25s–1m35s only:
%   ambisource detect single sphere examples/example_rec.wav 48000 out pngs res=1 fps=30 t0=1:25 t1=1:35
%
%   % Direct call with matrix:
%   detect_single_sphere(S, fs, 'out', 'pngs', 'res=2', 'hpf=80')
%

% =====================================================================
% DEFAULT PARAMETERS
% =====================================================================
P.res       = 1;      % degrees
P.hpf       = 150;    % Hz
P.order     = 4;      % IIR filter order
P.fps       = 30;     % output frame rate (for PNGs)
P.colormap  = 256;    % turbo() resolution
P.alpha_k   = 99;     % alpha-map compression
P.framelen  = 1;      % seconds per frame
P.t0        = 0;      % start time [s]
P.t1        = inf;    % end time [s] (inf = full length)

% =====================================================================
% HANDLE ZERO ARGUMENTS
% =====================================================================
if nargin == 0
    print_detect_single_sphere_help();
    return;
end

% =====================================================================
% BASIC ARGUMENT VALIDATION
% =====================================================================
if nargin < 3
    fprintf('ERROR: Not enough input arguments.\n\n');
    print_detect_single_sphere_help();
    return;
end

ambi_b = varargin{1};
fs     = varargin{2};
outdir = varargin{3};

if nargin >= 4 && ~startsWith(varargin{4}, "-") && ~contains(varargin{4}, "=")
    mode = varargin{4};
    opt_idx_start = 5;
else
    mode = 'json';
    opt_idx_start = 4;
end

% =====================================================================
% WAV FILE LOADING (if first argument is a filename)
% =====================================================================
if ischar(ambi_b) || isstring(ambi_b)
    wav_file = ambi_b;

    if ~exist(wav_file, 'file')
        error('Input WAV file not found: %s', wav_file);
    end

    [ambi_b, fs_wav] = audioread(wav_file);

    if size(ambi_b,2) ~= 4
        error('Input WAV must contain exactly 4 FOA channels (W,Y,Z,X).');
    end

    fs = fs_wav;   % override provided fs with actual sample rate
end

% =====================================================================
% PARSE OPTIONS (key=value pairs)
% =====================================================================
for k = opt_idx_start:nargin
    token = varargin{k};

    if ~contains(token, "=")
        fprintf('WARNING: ignoring invalid option "%s"\n', token);
        continue;
    end

    parts = split(token, "=");
    key   = lower(string(parts{1}));
    val   = string(parts{2});

    switch key
        case "res"
            P.res = str2double(val);
        case "hpf"
            P.hpf = str2double(val);
        case "order"
            P.order = str2double(val);
        case "fps"
            P.fps = str2double(val);
        case "colormap"
            P.colormap = str2double(val);
        case "alpha_k"
            P.alpha_k = str2double(val);
        case "framelen"
            P.framelen = str2double(val);
        case "t0"
            P.t0 = parse_time_string(val);
        case "t1"
            P.t1 = parse_time_string(val);
        otherwise
            fprintf('WARNING: unknown option "%s"\n', key);
    end
end

mode = lower(mode);

% =====================================================================
% VALIDATION
% =====================================================================
if ~exist(outdir,'dir')
    mkdir(outdir);
end

if ~isnumeric(ambi_b) || size(ambi_b,2) ~= 4
    error('ambi_b must be numeric Nx4 FOA matrix.');
end
if ~isnumeric(fs)
    error('fs must be numeric.');
end

% =====================================================================
% DEFINE SPHERICAL GRID FROM PARAMETER "res"
% =====================================================================
SPHERE_AZ = deg2rad(0:P.res:360-P.res);
SPHERE_EL = deg2rad(-90:P.res:90);

[AZ, EL] = meshgrid(SPHERE_AZ, SPHERE_EL);

gW = (1/sqrt(2))*ones(size(AZ));
gY = cos(EL).*sin(AZ);
gZ = sin(EL);
gX = cos(EL).*cos(AZ);

A = [gW(:).'; gY(:).'; gZ(:).'; gX(:).'];

% =====================================================================
% HIGH-PASS FILTER
% =====================================================================
hp = designfilt('highpassiir', ...
    'FilterOrder', P.order, ...
    'HalfPowerFrequency', P.hpf, ...
    'SampleRate', fs);

S = ambi_b;
for ii = 1:4
    S(:,ii) = filtfilt(hp, S(:,ii));
end

% =====================================================================
% FRAME SETUP WITH TIME RANGE
% =====================================================================
N          = size(S,1);
total_dur  = N / fs;

% Clamp t0,t1 to valid range
t0 = max(0, P.t0);
if isfinite(P.t1)
    t1 = min(P.t1, total_dur);
else
    t1 = total_dur;
end

start_sample = floor(t0 * fs) + 1;
end_sample   = floor(t1 * fs);

start_sample = max(1, start_sample);
end_sample   = min(N, end_sample);

win = P.framelen * fs;
hop = round(fs / P.fps);

last_start = end_sample - win + 1;
if last_start < start_sample
    warning('No frames to process in selected time range t0=%g, t1=%g.', t0, t1);
    frames = [];
else
    frames = start_sample:hop:last_start;
end

nF = numel(frames);
if nF == 0
    warning('No frames to process (signal too short for framelen=%g in selected range).', P.framelen);
end

% Preallocate per-frame results
az_deg   = nan(nF,1);
el_deg   = nan(nF,1);
strength = nan(nF,1);

% Prepare PNG output if needed
do_png = strcmp(mode, "pngs");
if do_png
    pngdir = fullfile(outdir, "frames");
    if ~exist(pngdir,'dir')
        mkdir(pngdir);
    end
    C = turbo(P.colormap);
end

% =====================================================================
% CORE PER-FRAME COMPUTATION (shared by JSON + PNG)
% =====================================================================
frame_idx = 0;

for i0 = frames
    frame_idx = frame_idx + 1;

    % 4x4 covariance matrix over the frame
    Sf = S(i0:i0+win-1,:);
    M  = (Sf.' * Sf) / win;          % 4x4

    % directional energy on the grid
    Hw = sum(A .* (M * A), 1);       % 1 x P
    denom = max(Hw);
    if denom <= 0
        denom = eps;
    end

    Hn = reshape(Hw / denom, size(AZ));   % normalized 0..1
    Hn = min(max(Hn,0),1);

    % find maximum direction (dominant source)
    [~, idx_max] = max(Hw);               % use unnormalized energy
    [row_max, col_max] = ind2sub(size(AZ), idx_max);
    az_rad = AZ(row_max, col_max);
    el_rad = EL(row_max, col_max);

    az_deg(frame_idx)   = rad2deg(az_rad);
    el_deg(frame_idx)   = rad2deg(el_rad);
    strength(frame_idx) = denom;          % peak energy in this frame

    % PNG output (optional)
    if do_png
        RGB   = ind2rgb(1 + floor((P.colormap-1)*Hn), C);
        Alpha = log1p(P.alpha_k * Hn) / log(1 + P.alpha_k);

        sec = floor((frame_idx - 1) / P.fps);
        mm  = floor(sec / 60);
        ss  = mod(sec, 60);
        ff  = mod(frame_idx - 1, P.fps);

        fname = sprintf('%02d-%02d-%02d.png', mm, ss, ff);
        imwrite(RGB, fullfile(pngdir, fname), 'Alpha', Alpha);
    end
end

% =====================================================================
% BUILD RESULT STRUCT FOR JSON
% =====================================================================
result_struct = struct( ...
    'azimuth',   az_deg, ...
    'elevation', el_deg, ...
    'strength',  strength, ...
    'frames',    nF, ...
    'fs',        fs, ...
    'samples',   N, ...
    'params',    P );

% =====================================================================
% JSON MODE
% =====================================================================
if strcmp(mode, "json")
    outfile = fullfile(outdir, "directions.json");
    txt = jsonencode(result_struct);

    fid = fopen(outfile, "w");
    fwrite(fid, txt, "char");
    fclose(fid);

    fprintf("JSON written: %s\n", outfile);
    return;
end

% =====================================================================
% PNG MODE (JSON already computed above)
% =====================================================================
if do_png
    fprintf("PNG frames written to: %s\n", pngdir);
    return;
end

fprintf('ERROR: unknown mode "%s"\n', mode);
print_detect_single_sphere_help();
end


% =====================================================================
% PARSE TIME STRING  (seconds or MM:SS)
% =====================================================================
function t = parse_time_string(val)
% Accepts:
%   "10"     -> 10 seconds
%   "3:25"   -> 3 minutes 25 seconds = 205
%
    v = char(val);
    if contains(v, ":")
        parts = split(v, ":");
        if numel(parts) ~= 2
            error('Invalid time format "%s". Use seconds or MM:SS.', v);
        end
        mm = str2double(parts{1});
        ss = str2double(parts{2});
        if isnan(mm) || isnan(ss)
            error('Invalid time value in "%s".', v);
        end
        t = 60*mm + ss;
    else
        t = str2double(v);
        if isnan(t)
            error('Invalid time value "%s". Use seconds or MM:SS.', v);
        end
    end
end


% =====================================================================
% HELP (from top comments)
% =====================================================================
function print_detect_single_sphere_help()
txt = help('detect_single_sphere');
fprintf('%s\n', txt);
end

