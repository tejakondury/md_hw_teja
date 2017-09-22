#!/bin/bash

for num in {30..50..1}
do 
 i=`echo "scale=2 ; ${num}/10" | bc`  # convert into floating point values

############################################input_file###########################################################
cat >in.run$i <<!

# ---------- Initialize Simulation --------------------- 
clear 
units metal 
dimension 3 
boundary p p p 
atom_style atomic 

# ---------- Variables --------------------- 
variable lat equal $i


# ---------- Create Atoms --------------------- 
#lattice has to be specified first -> all geometry commands are based on it
lattice fcc $i
#region ID style args keyword (0 1 means 0 lat) (specifies the simulation cell)
region	box block 0 1 0 1 0 1 units lattice
#create_box N region-ID (N=# of atom types)
create_box	1 box

lattice	fcc $i orient x 1 0 0 orient y 0 1 0 orient z 0 0 1  
#create_atoms type style
create_atoms 1 box
replicate 1 1 1

# ---------- Define Interatomic Potential --------------------- 
pair_style eam/alloy 
pair_coeff * * AlCu.eam.alloy Al
neighbor 2.0 bin 
neigh_modify delay 10 check yes 
 
# ---------- Define Settings --------------------- 
#compute ID group-ID style 
#potentail energy per atom
compute poteng all pe/atom
#the sum of all poteng 
compute eatoms all reduce sum c_poteng 


# ---------- Run Minimization --------------------- 
#So timestep start at 0
reset_timestep 0 
fix 1 all box/relax iso 0.0 vmax 0.001
thermo 10 
thermo_style custom step pe lx ly lz press pxx pyy pzz c_eatoms 
min_style cg 
minimize 1e-25 1e-25 0 0
#write_data optimized.data 

variable natoms equal "count(all)" 
variable teng equal "c_eatoms"
variable length equal "lx"
variable ecoh equal "v_teng/v_natoms"

print "Total energy (eV) = ${teng};"
print "Number of atoms = ${natoms};"
print "Lattice constant (Angstoms) = ${length};"
print "Cohesive energy (eV) = ${ecoh};"

print "All done!" 

!
#################################################end_input_file###########################################################



###################################################Run_job################################################################
cat >lammps$i.job <<!

#!/bin/bash

### Set the job name

#PBS -N MSE551

### Specify the PI group for this job

#PBS -W group_list=oiz

### Set the queue for this job as windfall or standard (adjust ### and #)

###PBS -q windfall

#PBS -q standard

### Set the number of nodes, cores and memory that will be used for this job. 

### "pcmem=6gb" is the memory attribute for all of the standard nodes

#PBS -l select=1:ncpus=1:mem=6gb:pcmem=6gb

#PBS -l place=free:shared

### Specify "wallclock time" required for this job, hhh:mm:ss

#PBS -l walltime=00:10:00

### Specify total cpu time required for this job, hhh:mm:ss

### total cputime = walltime * ncpus

#PBS -l cput=00:10:00

### cd: set directory for job execution, ~netid = home directory path

cd /extra/tejakondury/MSE551/Lab1/ex2/md_hw_teja_2

### Load required modules/libraries

module load lammps/gcc/17Nov16 

#export MPI_DSM_DISTRIBUTE

#export OMP_NUM_THREADS 1

mpirun -np 1 lmp_mpi-gcc -sf opt < in.run$i > out.run$i

!
#################################################End_Run_job###############################################################

qsub lammps$i.job

done



