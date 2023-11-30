function setup_subject_sims_tdcs(SUBJECT_s, SIMDIR, WDIR)
 
    % Setup Subject SimNIBS simulation files used for tDCS study modeling
    %
    % Miles Wischnewski & Taylor Berger, updated: 30 November, 2023

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% FUNCTION INPUTS:                                                               %%%
    %%% SIMDIR: SimNIBS 3.2 path                                                       %%%
    %%% WDIR: Working Diretory for Simulation                                          %%%
    %%% SUBJECT_s: Subject name, will be converted into string                         %%%
    %%% FUNCTION DEPENDENCIES:                                                         %%%
    %%% subject_dir: Subject Directory, contains FEM head mesh                         %%%
    %%% m2m_folder: SimNIBS generated folder, within Subject Directory                 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% t.mat: SimNIBS simulation structure in pathfem directory                       %%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% MATLAB Configuration
    % Add SimNIBS 3.2 to path
    addpath(genpath(SIMDIR))

    %% Directory Setup
    % Subject Name
    SUBJECT = num2str(SUBJECT_s);
    % Input Directories - Specific to Subject, same for all Simulations
    directory = strcat(WDIR, 'simulations/base_simulations/'); % Baseline simulations used as template for all subjects
    s_directory = strcat(WDIR, 'subjects/'); % Subjects
    subject_dir = strcat(s_directory, SUBJECT, '/'); % Subject Directory
    m2m_path = strcat(subject_dir, 'm2m_', SUBJECT); % Base Subject m2m_folder
    mhead=convertStringsToChars(strcat(subject_dir,SUBJECT,'.msh'));
    eeg_cap = strcat(m2m_path, '/eeg_positions/EEG10-10_UI_Jurak_2007.csv');
    fname_tensor = strcat(subject_dir, 'd2c_', SUBJECT, '/dti_results_T1space/DTI_conf_tensor.nii.gz');
    fn_tensor_nifti = fname_tensor;
   

    %% Simulation Specific information
    sim_list = GetSubDirsFirstLevelOnly(directory);
    for sim = 1:length(sim_list)
        sim_name = sim_list{sim};

        % Load in Template simnibs file
        template_sim = dir(strcat(directory, sim_name, '/*.mat'));
        t_ref = load(strcat(directory, sim_name, '/', template_sim.name));

        pathfem = strcat(subject_dir, 'simulations/', sim_name, '/');
        if ~exist(pathfem, 'dir')
            mkdir(pathfem)
        end

        %% Update Field Values
        t = sim_struct('SESSION');
        t.fields = t_ref.fields;
        t.map_to_fsavg = t_ref.map_to_fsavg;

        t.subpath = m2m_path;
        t.eeg_cap = eeg_cap;
        t.fnamehead = mhead;
        t.pathfem = pathfem;
        t.fname_tensor = fname_tensor;
        for i = 1:length(t_ref.poslist)
            t.poslist{i,1} = sim_struct('TDCSLIST')
            t.poslist{i,1}.cond = t_ref.poslist{i,1}.cond;
            t.poslist{i,1}.currents = t_ref.poslist{i,1}.currents;
            t.poslist{i,1}.fn_tensor_nifti = fn_tensor_nifti; % Only used for anistopic surfaces, not automatically generated for each subject
            t.poslist{i,1}.fnamefem=strcat(pathfem, SUBJECT, '_TDCS_1_scalar.msh');
            t.poslist{i,1}.electrode = t_ref.poslist{i,1}.electrode;
            for elec = 1:length(t.poslist{1, 1}.electrode)
                ernie_centre = t.poslist{1, 1}.electrode(elec).centre;
                ernie_ydir = t.poslist{1, 1}.electrode(elec).pos_ydir;
                % Convert from Ernie to MNI
                ernie_m2m = strcat(s_directory, 'ernie/m2m_ernie');
                mni_centre = subject2mni_coords(ernie_centre, ernie_m2m);
                mni_ydir = subject2mni_coords(ernie_ydir, ernie_m2m);
                % Convert from MNI to subject
                subject_centre = mni2subject_coords(mni_centre, m2m_path);
                subject_ydir = mni2subject_coords(mni_ydir, m2m_path);
                t.poslist{1, 1}.electrode(elec).centre  = subject_centre;
                t.poslist{1, 1}.electrode(elec).pos_ydir = subject_ydir;
            end
        end
        pathfem
        save(sprintf('%s/%s.mat',pathfem,'t'),'-struct','t');
        % Run Simulation
        run_simnibs(t)
        % Clears structure variable
        clear t
    end
end