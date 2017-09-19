#!/bin/bash

for i in {300..600..50}
do

cat >in.run.$i <<!

# Units energy:eV time:ps distance:angstrom flux:energy*velocity
#---------Sim variables---------------
variable fileprefix string  optimized.data
#variable temp_s equal '300.0'
variable press_s equal '1.0'
log log.${fileprefix}

#-----------Setup----------------------
units metal            #Energy = eV , Distance= Angstroms
dimension 3
boundary p p p         #Periodic boundary conditions 
atom_style atomic

# Read config files

read_data optimized.data
replicate 10 10 10

pair_style eam/alloy 
pair_coeff * *  Al99.eam.alloy Al
neighbor 2.0 bin 
neigh_modify delay 10 check yes 


#--------- NPT-------                                                                                                         
reset_timestep 0
timestep 0.001

thermo 1000
thermo_style custom step pe ke etotal enthalpy temp vol press
velocity all create $i 1518772 
fix 1 all npt temp $i $i 0.5 iso 0 0 5 
dump 2 all atom 2000 dump.npt.optimized.$i
run 60000
unfix 1
undump 2

######################################
# SIMULATION DONE
print "All done"
!
##############################################################################

# Write the job files
cat >job.$i <<!

#!/bin/bash
####### 
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
#PBS -l walltime=01:00:00
### Specify total cpu time required for this job, hhh:mm:ss
### total cputime = walltime * ncpus
#PBS -l cput=01:00:00


### cd: set directory for job execution, ~netid = home directory path
cd /extra/tejakondury/MSE551/hw3

### Load required modules/libraries
module load lammps/gcc/17Nov16 

#setenv MPI_DSM_DISTRIBUTE
#setenv OMP_NUM_THREADS 1

### run your executable program 
mpirun -np 1 lmp_mpi-gcc -sf opt < in.run.$i > out.run.$i
!
################################################################
### submit the job

qsub job.$i

done

