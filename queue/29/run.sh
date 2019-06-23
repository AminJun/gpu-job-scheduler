#Uskerim
#gpu 1
#!/bin/bash

source `which virtualenvwrapper.sh`
workon certifiable
cd /home/alishafahi/AJ/Certifiable
#export IMAGENET_DIR="/home/alishafahi/datasets/ImageNet/"
mkdir -p "outs"
mkdir -p "logs"
mkdir -p "output"

dataset="cifar10"
noise="0.50"
freq="1000"
tv_lambda="0.00005"
tv_factor="0.01"
steps="10"

if [ "${dataset}" == "cifar10" ] ; then
    arch="resnet110"
else
    arch="resnet50"
fi

job_name="grid_search_${tv_factor}_${tv_lambda}_${steps}"

python  "code/adv_certify.py" "${dataset}" "models/${dataset}/${arch}/noise_${noise}/checkpoint.pth.tar" "${noise}" \
        "output/${job_name}" --skip "${freq}" --batch 400 -t "${tv_factor}" -l "${tv_lambda}" \
        -s "${steps}" 1> "outs/${job_name}" 2> "logs/${job_name}" &

