#!/bin/sh
################################################
# whosonin.sh			               #
#  Reads in a txt file of the hostnames of the #
#  computers in the lab, then it pings them,   #
#  checking the ttl to determine Windows or    #
#  Linux (or off), and checks how many users   #
#  are logged in by sshing into the machine    #
# Author: davejoshmike			       #
# Date Started: 3/3/16			       #
# Lines of Code: 26			       #
################################################
hc=0 #host count
#need a text file of host names
if [ ! -f words.txt ]; then
	echo "File not found!"
	exit
fi

#reads words.txt into the host line-by-line,
#executing these commands for every line
while read host
do
	hc=$(($hc+1)) #increments host count

	#pings the host, taking only the line ttl is on
	#(grep ttl), shortening it to the 17 bytes on the 
	#tail end (tail -c 17) and reading only the first
	# 3 bytes of the shortened line (head -c 3)
	#Note: each character is a byte
	#Note: this command shortens the line to 2 bytes
	ttl=$(ping -c 10 $host | grep ttl | tail -c 17 | head -c 3)

	echo -n $hc") " #prints the host count for easier
			#reading

	#if length of $ttl is non-zero
	if [ -n "$ttl" ]
	then

		#if a computer has a ttl of 64 (meaning that it 
		#is in Linux)
		#then print out that it is in linux, and check 
		#to see who's logged in by sshing to the host	
		if [ $ttl -eq 64 ]
		then
			echo $host "is in Linux"
			#timeout ssh if not finished
			timeout 5 ssh -n -q $host 'who -q'

		#if a computer has a ttl of 128 (shortened to 2
		#bytes, so 28 in this case) that means the host
		#is in Windows, so print out a message saying it
		#is in Windows
		elif [ $ttl -eq 28 ]
		then
			echo $host "is in Windows"
		fi

	#if a computer could not be pinged, then print out that
	#the computer is off
	else
		echo $host "is off"
	fi
done < words.txt #exit loop when words.txt reachs eof
echo "END OF SCRIPT"
exit
