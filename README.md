# Job Scheduler
To create a new job use:
```bash 
jnewrun
``` 
It will create a new sh file automatically.

After creating the sh file, you need to add it to the queue. use: 
```bash 
jlunch SH_FILE.sh
```
to add your job to the queue. 

In order to see all the jobs in the queue you may use: 
```bash
jqstat
```

You can also cancel out a job by using :
```bash
jqrem
``` 
to remove a job from the queue. 


# Setup 
You need to set up a cronejob for "cron.sh". You also may need to set up the "PATH" and "LD\_LIB\_VARIABLE" for that matter. 
