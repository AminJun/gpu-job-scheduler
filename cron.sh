#!/bin/bash
export PATH="/home/alishafahi/bin:/home/alishafahi/.local/bin:/usr/local/cuda-8.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
export LD_LIBRARY_PATH="/usr/local/cuda-8.0/lib64:/usr/local/cudnn-6.0/lib64:" 
source "/home/alishafahi/jvidia/lib.sh" 
source "/home/alishafahi/.bashrc"
echo `date`
juse-gpus
