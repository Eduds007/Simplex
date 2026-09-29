function setup_paths()
%SETUP_PATHS Add the project folders and the SDP toolboxes to the MATLAB path.
%
%   Run once per MATLAB session from the repository root:
%       >> setup_paths
%
%   YALMIP, SDPT3 and SeDuMi are not versioned in this repository. Download
%   them and place them in the repository root (the default folder names from
%   the GitHub "Download ZIP" are recognised), or add them to the path yourself
%   before calling this function:
%       YALMIP  https://github.com/yalmip/YALMIP
%       SDPT3   https://github.com/sqlp/sdpt3
%       SeDuMi  https://github.com/sqlp/sedumi

    root = fileparts(mfilename('fullpath'));

    % Project folders
    addpath(fullfile(root, 'pendulum'));
    addpath(fullfile(root, 'ex2', 'utils'));

    % Third-party toolboxes: {display name, candidate folders, function that proves it is on the path}
    toolboxes = {
        'YALMIP', {'YALMIP-master/YALMIP-master', 'YALMIP-master', 'YALMIP'}, 'yalmip';
        'SDPT3',  {'sdpt3-master/sdpt3-master', 'sdpt3-master', 'sdpt3'},    'sqlp';
        'SeDuMi', {'sedumi-master/sedumi-master', 'sedumi-master', 'sedumi'}, 'sedumi';
    };

    missing = {};
    for i = 1:size(toolboxes, 1)
        [name, candidates, probe] = toolboxes{i, :};
        for c = candidates
            folder = fullfile(root, c{1});
            if isfolder(folder)
                addpath(genpath(folder));
                break
            end
        end
        if exist(probe, 'file')
            fprintf('  [ok]      %s\n', name);
        else
            fprintf('  [missing] %s\n', name);
            missing{end+1} = name; %#ok<AGROW>
        end
    end

    % Use a writable folder for Simulink cache/codegen files so they never
    % end up next to the models.
    buildDir = fullfile(root, 'build');
    if ~isfolder(buildDir)
        mkdir(buildDir);
    end
    Simulink.fileGenControl('set', 'CacheFolder', buildDir, ...
        'CodeGenFolder', buildDir, 'createDir', true);

    if isempty(missing)
        fprintf('Paths configured. Build artefacts go to %s\n', buildDir);
    else
        warning('setup_paths:missingToolbox', ...
            'Missing toolboxes: %s. See README.md for installation instructions.', ...
            strjoin(missing, ', '));
    end
end
