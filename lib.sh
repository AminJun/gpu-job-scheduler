#!/bin/bash
export JVIDIA_PATH="/home/alishafahi/jvidia"
function jqueue-free(){
	gpus=$(nvidia-smi | tail -n +25 | head -n -1 | while read line ; do echo "${line}" | awk '{print $2}' ; done | uniq )
	frees=$( cat "${JVIDIA_PATH}/gpus" | while read -n 1 c ; do if [ "${c}" != "" ] ; then echo "${c}"; fi ; done | while read i ; do if [[ ! $gpus == *"${i}"* ]] ; then echo "$i" ; fi ; done)
	count=$( echo ${frees} | tr -d ' \n' | wc -c)
	frees=$( echo ${frees} | sed 's/ /,/g')
	echo $count $frees
}
function jqstat(){
	jobs=$(ls "${JVIDIA_PATH}/queue/" | sort -h)
	echo -e "ID\t|USER\t|#GPUs\t|DATE\t\t\t\t|PATH"
	for i in ${jobs} ; do 
		path=$(cat "${JVIDIA_PATH}/queue/${i}/info.txt"| head -n 1 | tail -n 1 | tr -d '\n')
		date=$(cat "${JVIDIA_PATH}/queue/${i}/info.txt"| head -n 2 | tail -n 1 | tr -d '\n')
		user=$(cat "${JVIDIA_PATH}/queue/${i}/info.txt"| head -n 3 | tail -n 1 | tr -d '\n' | head -c 5)
		gpus=$(cat "${JVIDIA_PATH}/queue/${i}/info.txt"| head -n 4 | tail -n 1 | tr -d '\n')
		echo -e "${i}\t|${user}\t|${gpus}\t|${date}\t|${path}"
	done;
}
function jqrem(){
	if [ "${1}" != "" ] ; then 
	rm -r "${JVIDIA_PATH}/queue/${1}"
	fi
}
function jqstat-next-id(){
	last=$(ls "${JVIDIA_PATH}/queue/" | sort -h | tail -n 1)
	next=$((${last}+1))
	if [ "${next}" -gt 2000 ] ; then 
		next=1
	fi
	echo ${next}
}
function jqueue-next-run(){
	i=$(ls "${JVIDIA_PATH}/queue/" | sort -h | head -n 1)
	if [ "${i}" == "" ] ; then 
		return 0
	fi
	gpus=$(cat "${JVIDIA_PATH}/queue/${i}/info.txt"| head -n 4 | tail -n 1 | tr -d '\n')
	echo -e "${i}\t${gpus}"
}
function jattempt(){
	i=$(jqueue-next-run | awk '{print $1}')
	if [ "${i}" == "" ] ; then 
		return 0
	fi
	gpus=$(jqueue-next-run | awk '{print $2}')
	frees=$(jqueue-free)
	count=$(echo ${frees} | awk '{print $1}')
	frees=$(echo ${frees} | awk '{print $2}')
	if [ "${gpus}" -le "${count}" ] ; then 
		takec=$((${gpus}*2-1))
		take=${frees:0:$takec}
		export CUDA_VISIBLE_DEVICES=${take}
		jdeque
	fi
}
function jdeque(){
	i=$(jqueue-next-run | awk '{print $1}')
	path=$(cat "${JVIDIA_PATH}/queue/${i}/info.txt"| head -n 1 | tail -n 1 | tr -d '\n')
	date=$(cat "${JVIDIA_PATH}/queue/${i}/info.txt"| head -n 2 | tail -n 1 | tr -d '\n')
	user=$(cat "${JVIDIA_PATH}/queue/${i}/info.txt"| head -n 3 | tail -n 1 | tr -d '\n')
	gpus=$(cat "${JVIDIA_PATH}/queue/${i}/info.txt"| head -n 4 | tail -n 1 | tr -d '\n')
	source "${JVIDIA_PATH}/queue/${i}/run.sh" &
	mkdir -p "${JVIDIA_PATH}/archive/${i}/"
	mv "${JVIDIA_PATH}/queue/${i}" "${JVIDIA_PATH}/archive/${i}/`date`"
	len=$(jqstat | wc -l)
	if [ "${len}" == 1 ] ; then 
		source "${JVIDIA_PATH}/text.sh"
	fi
}
function jlunch(){
	id=`jqstat-next-id`
	jobp="${JVIDIA_PATH}/queue/${id}"
	mkdir -p "${jobp}"
	date=`date`
	path=`realpath "$1"`
	gpus=$(cat "${path}" | grep "#gpu" | head -n 1 | awk '{print $NF}')
	if [ "${gpus}" == "" ] ; then 
		gpus=1
	fi
	if [ "${gpus}" -gt 4 ] ; then 
		echo "Error, requesting more than 4 gpus" 
		return 0
	fi
	user=`whoami`
	echo -e "ID\t|USER\t|#GPUs\t|DATE\t\t\t\t\t|PATH"
	echo -e "${id}\t|${user}\t|${gpus}\t|${date}\t|${path}"
	echo ${path} > "${jobp}/info.txt"
	echo ${date} >> "${jobp}/info.txt"
	echo ${user} >> "${jobp}/info.txt"
	echo ${gpus} >> "${jobp}/info.txt"
	cp "${path}" "${jobp}/run.sh"
}
function jnewrun(){
	lastno=$(ls | grep ".sh" | grep "run" | sed 's/run//g; s/.sh//g' | sort -h | tail -n 1 )
	nextno=$((${lastno}+1))
	def_shname="run${nextno}"
	read -p "Name the file [default run(i).sh]: " shname
	shname=${shname:-$def_shname}
	if [[ ! "${shname}" == *".sh" ]] ; then 
		shname="${shname}.sh"
	fi
	echo "#Uskerim" > "${shname}"
	echo "Created ${shname}" 
	
	read -p "How many gpus do you need? [default 1]: " gpus
	gpus=${gpus:-1}
	echo "#gpu ${gpus}"  >> "${shname}"
	
	echo "How do you want to activate your virtual env? " 
	default_env="/home/alishafahi/virtualenvironment/"
	default_env_wrapper="virtualenvwrapper.sh"
	echo "1) ${default_env}"
	echo "2) ${default_env_wrapper}"
	read -p "[default 1]: " envchoice
	envchoice=${envchoice:-1}
	read -p "What is the virtual env's name? [default adv-defense]: " envname
	envname=${envname:-"adv-defense"}
	if [ "${envchoice}" == "1" ] ; then 
		echo "source ${default_env}${envname}/bin/activate" >> "${shname}"
	else
		echo "source \`which ${default_env_wrapper}\`" >> "${shname}" 
		echo "workon ${envname}" >> "${shname}"
	fi
	
	defcd="`pwd`"
	read -p "Enter the location to the runner [default ${defcd}]: " cddir
	cddir=${cddir:-$defcd}
	echo "cd ${cddir}" >> "${shname}"
	
	
	read -p "Enter all the commands that you need to run befor running python. [Leavy empty if none] " extracommands
	echo "${extracommands}" >> "${shname}"
	
	read -p "What's the outputfile? [default outs/(name).txt]: " outputdir
	runname=${shname%.*}
	outputdir=${outputdir:-"outs/${runname}.txt"}
	echo "mkdir -p \"${outputdir%/*}\"" >> "${shname}"
	
	read -p "Wha'ts the logfile? [default logs/(name).txt]: " logdir
	logdir=${logdir:-"logs/${runname}.txt"}
	echo "mkdir -p \"${logdir%/*}\"" >> "${shname}"
	
	read -p "Give me the run command [no defaults]: " runcommand
	if [ "${runcommand}" == "" ] ; then 
		echo "Error : The run command has no defaults, for instance use:"
		echo "main.py --train" 
		return 0
	fi 
	runcommand=$(echo ${runcommand} | sed 's/python //g')
	echo "python ${runcommand} 1> ${outputdir} 2> ${logdir} &" >> "${shname}"
	
	echo "Created ${shname}" 
	echo "Use: jlunch ${shname} to run"
}
function jqclear(){
	jqstat | awk '{print $1}' | tail -n +2 | while read id ; do jqrem "${id}" ; done ;
}
function jvtext-enable(){
	sed -i "s/post=./post=1/g" "${JVIDIA_PATH}/text.sh"
}
function jvtext-disable(){
	sed -i "s/post=./post=0/g" "${JVIDIA_PATH}/text.sh"
}
function jqueue-setgpus(){
	echo "$1" > "${JVIDIA_PATH}/gpus"
}
