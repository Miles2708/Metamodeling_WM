function subject_sim_summary(SUBJECT_s, SIMDIR, WDIR)

    % Setup Subject Summary of SimNIBS simulations
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
    %%% data_allstudies_template.mat: structure template for study data                %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% data_allstudies.mat: SimNIBS simulation summary in subject directory           %%% 
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
    subject_sim_dir = strcat(subject_dir, 'simulations/'); % Simulation Directory   

    %% Load in Summary Templates
    template_path = strcat(WDIR, 'simulation_files/');
    load(strcat(template_path, 'montage_list.mat')) % montage_list
    data_allstudies = load(strcat(template_path, 'data_allstudies_template.mat')); % structure file


    %% Simulation Specific information
    for sim = 1:length(montage_list)
        sim_name = montage_list{sim};

        m_path = strcat(subject_dir, 'simulations/', sim_name, '/subject_overlays/', SUBJECT, '_TDCS_1_scalar_central.msh');
        m_sim = mesh_load_gmsh4(m_path)
        gm_sim = mesh_extract_regions(m_sim, 'elemtype', 'both', 'region_idx', 1002); %volume
        gm_normE(:, sim) = gm_sim.node_data{2, 1}.data;
        fclose('all')
    end

    data_allstudies.gm_normElist = gm_normE;

    % Save Output
    save(sprintf('%s/%s.mat',subject_dir, 'data_allstudies'),'-struct','data_allstudies');
end