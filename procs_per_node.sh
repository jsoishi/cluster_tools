#
# procs_per_node: return the number of processors running python3 
#                 tasks on a given node, and their total memory usage
# usage:
#    procs_per_node.sh JOBID
#
# where JOBID is the SLURM job id. 
# Note this script requires SLURM and ssh access to nodes
#
#
#/bin/env bash
JOBID=$1
# squeue returns ranges, e.g. node001-003, node005-009
# here we break this up and construct an array of node numbers to query
hostlist=`squeue --job $JOBID | grep node | tr -s ' ' | cut -d ' ' -f 9 | sed 's/node\[*\([,[:digit:]-]\+\)\]*/\1/' | sed 's/,/ /g'`
nodelist=()
for h in $hostlist; do
    start=$(echo $h | cut -f1 -d-)
    end=$(echo $h | cut -f2 -d-)
    nodelist+=`seq $start $end`
    nodelist+=' '
done
echo $nodelist
for i in $nodelist; do
    printf -v nodename "node%03i" $i
    count=`ssh $nodename "ps aux | grep [p]ython3 | grep -v mpirun| grep -v mpiexec | wc -l"`
    memory=`ssh $nodename "ps aux | grep [p]ython3 | grep -v mpiexec | grep -v mpirun | tr -s ' ' | cut -d ' ' -f 4" | awk '{s+=$1} END {print s}' -`
    echo "$nodename: nproc=$count tot_memory=$memory GB"
done
