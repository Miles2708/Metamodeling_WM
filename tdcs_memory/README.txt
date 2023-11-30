###   Usage  ###
# File Structure

subjects: Folder containing subject directories
|_ SUBJECT: Subject specific Directory
   |_ SUBJECT.msh - Subject specific FEM volumetric head mesh
   |_ m2m_SUBJECT: SimNIBS generated directory (follow head mesh generation instructions available on SimNIBS github: https://simnibs.github.io/simnibs/build/html/index.html)
   |_ simulations: SimNIBS modeling results directory generated within "setup_subject_sims_tdcs.mat"

simulations: Simulation configuration Directory
|_ base_simulations: Directory containing studies used within this meta-analysis
   |_ STUDY_ID: Study Specific Directory
      |_ simnibs_simulation_########-######.mat: SimNIBS configuration file

simulation_files: Directory of matlab functions to perform analysis (in order of execution)
|_ setup_subject_sims_tdcs.m: sets up subject specific tdcs simulation files and runs simulation 
|_ subject_sim_summary.m: generates study simulation summary file used for analysis
|_ analysis_subject.m: performs subject specific meta-analysis
|_ data_allstudies_template.mat: template structure for subject summary file
|_ montage_list.mat: list of study montages included in this meta-analysis

analysis: Directory of subject specific meta-analysis results
|_ SUBJECT: Subject Specific Analysis Directory
