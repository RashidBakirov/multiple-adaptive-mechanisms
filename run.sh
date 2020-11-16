#it is possible to run the experiments paralelly using q (qsub) option (preferred) or b option (sequentially)
if [ "$1"="b" ]
then
   run_command="bash"
else
	if [ "$1"="q" ]
       	then
		run_command="qsub -l q=compute"
	else
		echo "Select either b option for bash or q for qsub"
		exit
	fi
fi


#this runs all of the classification experiments. All the results will be saved in /results folder

#SABLE commeted as the code is not available
#bash SABLE.sh $run_command
bash bDWM.sh $run_command
bash bPL.sh $run_command
bash bLB.sh $run_command
bash bBLAST.sh $run_command

