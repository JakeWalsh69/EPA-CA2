#!/bin/bash

# Command: "sudo yum install sysstat" used to install sysstat on Fedora VM.

# If a file called results.dat and/or data.txt exists, 
# it will be removed each time the script is run.
rm results.dat
rm data.txt

# Formatting the headers within the results.dat file.
printf "C0\tN\tidle\n" >> results.dat

# Creating a variable c to keep track of the word count within data.txt.
c=0

# For loop to iterate through the loadtest 5 times.
for l in {1..5}
do
	# Timeout command is assigned value of l in for loop to iterate 
	# through the loadtests correctly and avoid finishing with duplicate values.
	timeout $l ./loadtest $l
	
	# Appending mpstat data to data.txt file to be read at the end of each iteration.
	mpstat >> data.txt

	# Assigning the current word count of data.txt to the variable c.
	c=`cat data.txt | wc -l`

	# Appending the word count and iteration values to results.dat
	# to be used as values for C0 and N columns respectively.
	printf "$c\t$l" >> results.dat

	# Appending an extra tab for formatting purposes.
	printf "\t" >> results.dat
	
	# Using awk to obtain and print the 12th header of the data.txt file.
	# This value (idle) will then be appended to results.dat at the end of the current line. 
	awk '{print $12}' data.txt | tail -n1 >> results.dat
	
	# This line is purely for the users benefit so that they know what is happening
	# while the loadtest is running.
	echo "Iteration $l of 5 completed."
done

# Displaying all contents of the results.dat file after the loadtest has finished.
printf "\nContents of results.dat\n"
cat results.dat
