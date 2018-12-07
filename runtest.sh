#!/bin/bash

# Command: "sudo yum install sysstat" used to install sysstat on Fedora VM.

# Check to ensure that value is passed when running the script, if not program exits.
if [[ -z "$1" ]]; then
   echo "Usage $0 <loadtest>"
   exit 1
fi

# Check if value entered is greater than 0, if not program exits.
if [[ "$1" -lt 1 ]]; then
   echo "ERROR: Value must be greater than 0"
   exit 1;

# Chec if value entered is less than or equal to 50, if not program exits.
elif [[ $1 -gt 50 ]]; then
   echo "ERROR: Value must not exceed 50"
   exit 1;
fi

# If a file called stats.dat and/or findings.txt exists, 
# it will be removed each time the script is run.
rm stats.dat
rm findings.txt

# Formatting the headers within the stats.dat file.
printf "C0\tN\tidle\n" >> stats.dat

# Creating a variable c to keep track of the word count within findings.txt.
c=0
# Creating a variable m to store the value entered by the user to be utilized in for loop.
m=$1

# For loop to iterate through the loadtest $m times.
for (( l=1; l<=$m; l++ ))
do
	# Timeout command is assigned value of 10 to iterate through the loadtests
	# for 10 seconds each time to avoid finishing with duplicate values.
	timeout 10 ./loadtest 10
	
	# Appending mpstat data to findings.txt file to be read at the end of each iteration.
	mpstat >> findings.txt

	# Assigning the current word count of synthetic.dat to the variable c.
	let c+=`cat synthetic.dat | wc -l`

	# Appending the word count and iteration values to stats.dat
	# to be used as values for C0 and N columns respectively.
	printf "$c\t$l" >> stats.dat

	# Appending an extra tab for formatting purposes.
	printf "\t" >> stats.dat
	
	# Using awk to obtain and print the 12th header of the findings.txt file.
	# This value (idle) will then be appended to stats.dat at the end of the current line. 
	awk '{print $12}' findings.txt | tail -n1 >> stats.dat
	
	# This line is purely for the users benefit so that they know what is happening
	# while the loadtest is running.
	echo "Iteration $l of $m completed."
done

# Displaying all contents of the stats.dat file after the loadtest has finished.
printf "\nContents of stats.dat\n"
cat stats.dat
