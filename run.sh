#!/bin/bash

for num in {1..30..1}
do 
  i=`echo "scale=2 ; ${num}/10" | bc`  # convert into floating point values


############################################input_file###########################################################
cat >in.run$i <<!

units lj

atom_style atomic

boundary p p p

lattice sc 1.0


# create simulation cell

region r1 block -5.0 5.0 -5.0 5.0 -5.0 5.0

create_box 1 r1


# required must come after box is created

mass 1 1.0


# create two atoms, 

create_atoms 1 single  0.0 0.0 0.0

create_atoms 1 single  $i 0.0 0.0
# set non-bonded potential

pair_style lj/cut 5.0

pair_coeff 1 1 1.0 1.0



#velocity all create 1.0 54321 mom no rot no



run_style verlet

timestep  0.005   



#fix f1 all nve



minimize 1.0e-10 1.0e-10 0 0

write_data LJoptimized$i.data
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

#PBS -l walltime=00:15:00

### Specify total cpu time required for this job, hhh:mm:ss

### total cputime = walltime * ncpus

#PBS -l cput=00:15:00




### cd: set directory for job execution, ~netid = home directory path

cd /extra/tejakondury/MSE551/Lab1/ex1/md_hw_teja

### Load required modules/libraries

module load lammps/gcc/17Nov16 

#export MPI_DSM_DISTRIBUTE

#export OMP_NUM_THREADS 1

mpirun -np 1 lmp_mpi-gcc -sf opt < in.run$i > out.run$i

!
#################################################End_Run_job###############################################################

qsub lammps$i.job

done



