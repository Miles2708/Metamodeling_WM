function analysis_subject(SUBJECT_s, SIMDIR, WDIR)

    % Meta-analytic E-field analysis of prefrontal anodal tDCS studies
    % in relation to behavioral effect sizes LEFT HEMISPHERE
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
    %%% data_allstudies.mat: structure file, breaking down study & simulation results  %%%
    %%% montage_list.mat: montage analysis list                                        %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% mesh_corr_accuracy.msh: accuracy vs RT in analysis directory                   %%% 
    %%% mesh_corr_RT.msh: correlation of RT in analysis directory                      %%%   
    %%% mesh_corr_online.msh: online vs offline in analysis directory                  %%% 
    %%% mesh_corr_accuracy.msh: accuracy vs RT in analysis directory                   %%% 
    %%% mesh_corr_offline.msh: correlation of offline in analysis directory            %%% 
    %%% mesh_corr_verbal.msh: verbal vs visuospatial in analysis directory             %%% 
    %%% mesh_corr_visuospatial.msh: correlation of visuospatial in analysis directory  %%% 
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
    m2m_path = strcat(subject_dir, 'm2m_', SUBJECT); % Base Subject m2m_folder


    load(strcat(subject_dir, 'data_allstudies.mat')); % structure file

    %% Load in Summary Templates
    template_path = strcat(WDIR, 'simulation_files/');
    load(strcat(template_path, 'montage_list.mat')) % montage_list


    %--------------------------------------------------------------------------

    %% Analysis of PEC values

    %--------------------------------------------------------------------------

    analysis_dir = strcat(WDIR, 'analysis/', SUBJECT, '/');
    if ~exist(analysis_dir, 'dir')
        mkdir(analysis_dir)
    end  
   
    %% correlation between hedges g and norm E field
    % Here we correlate the normE values of each study with hedgesg. This is
    % what in the paper is refered to as PEC value.

    %% Select outcomes related to accuracy vs RT
    %note that other tasks types (= 4-9) are not used given in this
    %example given their limited sample size
    j=1;
    k=1;
    for i = 1:amount_of_meshes
        if outcome(i) == 1 || outcome(i) == 3 %1 Accuracy; 3 D 
            gm_normE_accuracy(:,j) = gm_normElist(:,i);
            hedgesg_accuracy(j) = hedgesg(i);
            j = j+1;
        elseif outcome(i) == 2
            gm_normE_RT(:,k) = gm_normElist(:,i);
            hedgesg_RT(k) = hedgesg(i);
            k = k+1;
        end
    end
    clear k
    clear j

    normE_corr_accuracy  = corr(gm_normE_accuracy', hedgesg_accuracy');
    normE_corr_RT  = corr(gm_normE_RT', hedgesg_RT');

    %% Select outcomes related to online vs offline
    j=1;
    k=1;
    for i = 1:amount_of_meshes
        if onoff(i) == 1 
            gm_normE_online(:,j) = gm_normElist(:,i);
            hedgesg_online(j) = hedgesg(i);
            j = j+1;
        elseif onoff(i) == 2
            gm_normE_offline(:,k) = gm_normElist(:,i);
            hedgesg_offline(k) = hedgesg(i);
            k = k+1;
        end
    end
    clear k
    clear j

    normE_corr_online  = corr(gm_normE_online', hedgesg_online');
    normE_corr_offline  = corr(gm_normE_offline', hedgesg_offline');

    %% Select outcomes related to verbal vs visuospatial
    j=1;
    k=1;
    for i = 1:amount_of_meshes
        if task_type1(i) == 1
            gm_normE_verbal(:,j) = gm_normElist(:,i);
            hedgesg_verbal(j) = hedgesg(i);
            j = j+1;
        elseif task_type1(i) == 2
            gm_normE_visuospatial(:,k) = gm_normElist(:,i);
            hedgesg_visuospatial(k) = hedgesg(i);
            k = k+1;
        end
    end
    clear k
    clear j

    normE_corr_verbal  = corr(gm_normE_verbal', hedgesg_verbal');
    normE_corr_visuospatial  = corr(gm_normE_visuospatial', hedgesg_visuospatial');


    %% make new meshes setup
    %here I predetermine some variables so that I later can use them to make
    %all the custom meshes
    
    sim = 1;
    sim_name = montage_list{sim};
    

    %create a new standard mesh that can be overwritten later
    m_path = strcat(subject_dir, 'simulations/', sim_name, '/subject_overlays/', SUBJECT, '_TDCS_1_scalar_central.msh');
    m_sim = mesh_load_gmsh4(m_path);

    %extract gm of the new standard mesh
    gm_sim = mesh_extract_regions(m_sim, 'elemtype', 'both', 'region_idx', 1002); %volume


    %% create mesh for PEC values
    % accuracy vs RT
    gm_corr_accuracy = gm_sim;
    gm_corr_accuracy.node_data{field_idx_normE}.data = normE_corr_accuracy;
    gm_corr_accuracy.node_data{field_idx_normE}.name = 'corr accuracy'; %change name of label
    mesh_save_gmsh4(gm_corr_accuracy, strcat(analysis_dir, 'mesh_corr_accuracy'));

    gm_corr_RT = gm_sim;
    gm_corr_RT.node_data{field_idx_normE}.data = normE_corr_RT;
    gm_corr_RT.node_data{field_idx_normE}.name = 'corr RT'; %change name of label
    mesh_save_gmsh4(gm_corr_RT, strcat(analysis_dir, 'mesh_corr_RT'));

    %online vs offline
    gm_corr_online = gm_sim;
    gm_corr_online.node_data{field_idx_normE}.data = normE_corr_online;
    gm_corr_online.node_data{field_idx_normE}.name = 'corr online'; %change name of label
    mesh_save_gmsh4(gm_corr_online, strcat(analysis_dir, 'mesh_corr_online'));

    gm_corr_offline = gm_sim;
    gm_corr_offline.node_data{field_idx_normE}.data = normE_corr_offline;
    gm_corr_offline.node_data{field_idx_normE}.name = 'corr offline'; %change name of label
    mesh_save_gmsh4(gm_corr_offline, strcat(analysis_dir, 'mesh_corr_offline'));

    %verbal vs visuospatial
    gm_corr_verbal = gm_sim;
    gm_corr_verbal.node_data{field_idx_normE}.data = normE_corr_verbal;
    gm_corr_verbal.node_data{field_idx_normE}.name = 'corr verbal'; %change name of label
    mesh_save_gmsh4(gm_corr_verbal, strcat(analysis_dir, 'mesh_corr_verbal'));

    gm_corr_visuospatial = gm_sim;
    gm_corr_visuospatial.node_data{field_idx_normE}.data = normE_corr_visuospatial;
    gm_corr_visuospatial.node_data{field_idx_normE}.name = 'corr visuospatial'; %change name of label
    mesh_save_gmsh4(gm_corr_visuospatial, strcat(analysis_dir, 'mesh_corr_visuospatial'));

end