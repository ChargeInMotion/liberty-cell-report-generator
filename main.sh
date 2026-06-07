#!/bin/bash

Help(){
echo "######################################################      HELP    ######################################################################"
echo

printf "Description: This script will fetch information of standard cells from .lib file as per user requirement and generate HTML report\n             automatically and user can send this generated report through email with the help of script.\n"

echo "1. To run the script, please enter ./main.sh or bash main.sh"

echo "2. User will get these options :"
	 printf "%s\t 1.Worst case\n"
	 printf "%s\t 2.Best case\n"
	 printf "%s\t 3.Help\n"
	 printf "%s\t 4.Exit\n"

echo "3. User can get information of cell for:"
	 printf "%s\t 1.Worst case\n "
	 printf "%s\t 2.Best case\n"
echo "4. If user wants help, then go for option 3. "
echo "   And if wants to exit the script then choose option 4. "
	 
echo "5. The file (fast.lib and slow.lib) needs to be present at working directory. Otherwise error message will display."
echo
echo "6. The script will ask from the user : Do you know the cell name?y/n" 
echo "   If user selects n/N , then cell names with all driving strengths will  be displayed on the terminal as per these categories."
echo "

         1. BASIC GATES(INV,AND,OR,NAND,NOR,XOR,XNOR,BUF,TBUF)
	 2. MULTIPLEXER
	 3. HAFA
	 4. TIE CELL
	 5. AOI
	 6. OAI
	 7. BOOLEAN FUNCTION
	 8. LATCH
	 9. FLIP-FLOP
	 10.CLKGATES  "
echo
echo "7. If user selects y/Y then user should Enter the full cell name in UPPERCASE- ."
echo "   If user enters wrong name an error message will display."
echo "8. After entering the cell name the user will get the particular cell information as per these categories, by selecting the index number:"
echo "

	1) Model	3) Operating Condition	5) Leakage Power	7) Pin Information	9) Internal Power	11) Previous Menu

	2) Units	4) Area			6) Rail Connection	8) Timing		10) Whole Information	12) Exit
"
       


echo "   suboptions are there in the timing information, user can select that option according to the requirement, through index number."

echo "9. Option 11. is for Main menu and if user want to exit the script then go for the option number 12. "
echo

echo "10. At the background the selected information of the cell  will be saved in the report.html file automatically in the format of tables."
echo "11. If user exit the script,then it would ask :  Enter recipient's email address, whom you wish to sent the work report:"
echo "    After entering the valid mail id, user can send mail of the generated report. "
   
echo
echo "12. Then script will exit. "
echo
}

model() {
		#MODEL_WITH_HTML_REPORT_GENERATION
		echo -e "\nShowing Initial Information of the $filename of MODEL: "
		echo "<table border="5" bordercolorlight="#b9dcff" bordercolordark="#006fdd"  width="290">
		<tr>
		<th bgcolor="#bfbfbf" ><center>Model</center></th>
		</tr>" >> report.html
	
		while read line ;do
		if [[ $line =~ ' model' ]];then
		#if any line contains the specified REGEX then it will be printed
		echo "$line"
		echo  "<tr>
		       <td>$line</td>
		       </tr>" >> report.html
		fi
		done < $filename #"$filename" contains the name of the input .lib file
		echo "</table>" >> report.html
}
units() {
		#UNIT_WITH_HTML_REPORT_GENERATION
		echo -e "\nShowing Initial Information of the $filename of UNITS: "
		echo "<table border="5" bordercolorlight="#b9dcff" bordercolordark="#006fdd"  width="290">
		<tr>
		<th bgcolor="#bfbfbf" ><center>Units</center></th>
		</tr>" >> report.html

		while read line ;do
		if [[ $line =~ '_unit' ]]; then
		echo $line
		echo  "<tr>
		       <td>$line</td>
		       </tr>" >> report.html
		fi
		done <<< $(sed 's/[;),]//g;s/"//g;s/(/: /' $filename) #"$filename" contains the name of the input .lib file
		#if any line contains the specified REGEX then it will be feeded as input to while loop
		echo "</table>" >> report.html
}
operating_condition() {
		#OPERATING_CONDITION_WITH_HTML_REPORT_GENERATION
		echo -e "\nShowing Initial Information of the $filename of OPERATING CONDITION"
		echo "<table border="5" bordercolorlight="#b9dcff" bordercolordark="#006fdd"  width="290"> 
		<tr>
		<th bgcolor="#bfbfbf" ><center>Operating Condition</center></th> 
		</tr>"  >> report.html

		while read line ; do
		echo "$line"
		echo "<tr> 
		<td>$line</td> 
		</tr>" >> report.html
		done <<< $(cat $filename | egrep -A 5  operating_conditions  | head -6 | tail -5 | sed 's/[;)]//g;s/(/ :/')
		#if any line contains the specified REGEX then it will be feeded as input to while loop
		echo "</table>" >> report.html
}
area(){		
		#AREA_WITH_HTML_REPORT_GENERATION
		area=$(echo "$cell_information" | egrep 'area'| awk '{print $3}' | sed 's/;//') 
		echo -e "\tAREA=$area\n"
		echo "<table border="5" bordercolorlight="#b9dcff" bordercolordark="#006fdd"  width="290">
		<tr>
		<th bgcolor="#bfbfbf" ><center>Area of $cell_name</center></th>
		</tr>
		<tr>
		<td>$area</td>
		</tr>
		</table>" >> report.html
}
leakage_power(){
		#LEAKAGE_POWER_WITH_HTML_REPORT_GENERATION
		leakage_power=$(echo "$cell_information" | egrep 'leakage' | awk '{print $3}' | sed 's/;//')
		echo -e "\tLeakage Power=$leakage_power\n"
		echo "<table border="5" bordercolorlight="#b9dcff" bordercolordark="#006fdd"  width="290">
		<tr>
		<th bgcolor="#bfbfbf" ><center>Leakage Power of $cell_name</center></th>
		</tr>
		<tr>
		<td>$leakage_power</td>
		</tr>
		</table>" >> report.html
}
rail(){		
		#RAIL_CONNECTION_WITH_HTML_REPORT_GENERATION
		rail=$(echo "$cell_information" | egrep 'rail' | awk '{print $2 $3}')
		echo -e "\tRail Connection=$rail\n"
		echo "<table border="5" bordercolorlight="#b9dcff" bordercolordark="#006fdd"  width="290">
		<tr>
		<th bgcolor="#bfbfbf" ><center>Rail Connection of $cell_name</center></th>
		</tr>
		<tr>
		<td>$rail</td>
		</tr>
		</table>" >> report.html
}
pin(){
		#PIN_INFORMATION
		pin_direction=$( echo "$cell_information"| sed -rn '/pin\(.+\)\s+\{$/{N;p}'| sed -r 's/[{}]//g')
		#PIN_DIRECTION
		echo -e "\tPin Direction\n\n$pin_direction\n"
		#PIN_TIMING
		echo -e "\tPin Information\n\n"
		sed -nr "/$cell_name/,/^}/p" $filename | sed -rn '/pin\(.+\)/N;/input/,/: output/p' | sed -rn '/pin\(.+\)/N;/output/d;p' | sed 's/index_1/INPUT_TRANS/;s/index_2/OUTPUT_CAP/;s/\\//g;s/\;//;s/,/ /g;s/\"/ /g' | awk '{print $0}/INPUT_TRANS|OUTPUT_CAP/{print "        "$1" : " "MIN="$3 " & MAX="$9}' | sed -r '/INPUT_TRANS \(| OUTPUT_CAP \(/d;s/\(.+template.+\)//' | awk '{print $0}/values \( [0-9]/{print "        "$1" : " "MIN="$3 " & MAX="$9}' | sed -r '/values\s+\(\s+[0-9]/d' | sed -r '/values \(/{N;N;N;N;N;N;N;s/\n/ /g}' | awk '{print $0}/values \(/{print  "      AVRG_VALUES : MIN="$3 " & MAX="$51}' | sed -r '/values \(/d;s/values/ANRG_VALUES/;/_power \{/{N;N;N;s/\n/  /g};/capacitance/{N;N;s/\n/  /g};/related_pin/{N;s/\n/ /g};/_constraint/{N;N;s/\n/ /g};/when :/{N;s/\n/     /};/pin\(.+\)/{N;s/\n/ /};s/\(\)//;s/\{/:-/g;s/\}/ /g;s/values :/AVRG_VALUES :/;s/pin\(.+\)/                                 \U&/;/direction/{N;s/\n/\n\n/};s/[a-Z]+_*.* :/\U&/g;s/INPUT_SIGNAL_LEVEL : RAIL_VDD//'
		
}
timing(){	
		#OPERATING_CONDITION
		res=$(echo "$cell_information" | sed -n "/timing/,/}/p")
		echo "$res"
}
internal_power(){
		res=$(echo "$cell_information" | sed -n "/internal_power/,/}/p")
		echo "$res"
}
file_check(){
		check_file=$(ls| egrep "$filename")
		if [[ ! $check_file =~ '.' ]];then
			{
			echo -e "\nFile=\"$filename\" is not present in the current working directory which is necessary for the further operations,Please make it available and try again."
			exit
			}
		fi
}
email(){	#it will ask the user to enter the recipient's email address
		
		read -p "Enter recipient's email address, whom you wish to sent the Work report:" email_id
		#"email_id" stores the user input of recipient's email address
		confirm=$(echo $email_id | egrep '[A-Za-z0-9._-]+@[A-Za-z0-9._-]+\.[A-Za-z.]+'| wc -L)
		#"confirm" varible will be "0" if the email id entered by the user is invalid
		if [[ $confirm -ne 0 ]];then
			{
			#if valid email address is given the email will be sent
			mail -s "$(echo -e "Work report\nContent-Type: text/html")" $email_id <  report.html
			echo "Email Sent Successfully"
			exit
			}
		else
			{
			#if valid email address is not given the email will not be sent
			echo "You have entered an invalid Email address, Please check the email and try again"
			email
			}
		fi
		
}
choice(){	#it will ask the user does he/she wants to send the work report through email or not
		end_time
		while :
		do
		read -p "Do you wish to sent work report through email?(y/n):" choose
				
			case $choose in
			
				"y" | "Y" )	#If "yes", Script will exit after sending the email
					email
					;;

				"N" | "n")	#If "no", Script will exit without sending the email
					exit
					;;
				*)	#If invalid input is given, Script ask again for yes/no
					echo "You have entered an invalid input, Please try again"
					choice
					
					;;
			esac
		done
}
no(){	
	#ALL_CELL_LIST_WITH_DRIVE_STRENGTH

	total_cell_count=$(egrep -o '^cell\s\(.+\)' $filename | awk '{print $2}' | sed 's/[()]//g' | wc -l)
	echo -e "\nTo select an option,type in it's serial number and press enter key\n"
	echo "These are categories of $total_cell_count Standard cells available in the file:"
	echo

	select answer4 in "INV" "OR" "AND" "BUF" "NAND" "NOR" "XOR" "XNOR" "TBUF" "Multiplexer" "HAFA" "Tie Cell" "AOI" "OAI" "Boolean Function" "Latch" "Flip-Flop" "CLKGATE" "Main Menu" "Exit";do

		case $answer4 in

		"INV")  #INV
			echo -e "\n##### INV #####\n" 
			awk 'BEGIN{i=0}/cell \(INV.+\)/{i++;printf  i"."" ";print  $2}' $filename | sed 's/[()]//g' | column -x
			break
                	;;

              	"OR")  #OR
			echo -e "\n##### OR #####-\n"
			awk 'BEGIN{i=0}/cell \(OR.+\)/{i++;printf i"." " ";print $2}' $filename | sed 's/[()]//g' | column -x
			break	
              		;;

              	"AND")  #AND
			echo -e "\n##### AND #####\n"
			awk 'BEGIN{i=0}/cell \(AND.+\)/{i++;printf i"." " ";print $2}' $filename | sed 's/[()]//g' | column -x
			break
               		;;

             	"BUF")  #BUF
			echo -e "\n##### BUF #####\n"
			awk 'BEGIN{i=0}/cell \(BUF.+\)/{i++;printf i".";print $2}' $filename | sed 's/[()]//g' | column -x
			break
               		;;

             	"NAND")  #NAND
			echo -e "\n##### NAND #####\n"
			awk 'BEGIN{i=0}/cell \(NAND.+\)/{i++;printf i".";print $2}' $filename | sed 's/[()]//g' | column -x
			break
               		;;

              	"NOR")  #NOR
			echo -e "\n##### NOR #####\n"
			awk 'BEGIN{i=0}/cell \(NOR.+\)/{i++;printf i".";print $2}' $filename | sed 's/[()]//g' | column -x
			break
                	;;

              	"XOR")  #XOR
			echo -e "\n##### XOR #####\n"
			awk 'BEGIN{i=0}/cell \(XOR.+\)/{i++;printf i".";print $2}' $filename | sed 's/[()]//g' | column -x
			break
              		;;

              	"XNOR")  #XNOR
			echo -e "\n##### XNOR #####\n"
			awk 'BEGIN{i=0}/cell \(XNOR.+\)/{i++;printf i".";print $2}' $filename | sed 's/[()]//g' | column -x
			break
               		;;

              	"TBUF")  #TBUF
			echo -e "\n##### TBUF #####\n"
			awk 'BEGIN{i=0}/cell \(TBUF.+\)/{i++;printf i".";print $2}' $filename | sed 's/[()]//g' | column -x
			break
               		;;

          	"Multiplexer") #MULTIPLEXER
			echo -e "\n##### MULTIPLEXER #####\n"
			awk 'BEGIN{i=0}/cell \(.?MX.+\)/{i++;printf i".";print $2}' $filename | sed 's/[()]//g' | column -x
			break
             		;;

          	"HAFA") #HALF_ADDER_FULL_ADDER
			echo -e "\n##### HAFA #####\n"
			awk 'BEGIN{i=0}/cell \(ADD.+\)/{i++;printf i"." " ";print $2}' $filename | sed 's/[()]//g' | column -x
			break
              		;;

          	"Tie Cell") #TIE_CELL	
			echo -e "\n##### TIE CELL #####\n"
			awk 'BEGIN{i=0}/cell \(TIE.+\)/{i++;printf i"." " ";print $2}' $filename | sed 's/[()]//g' | column -x
			break
             		;;

          	"AOI") #AOI
			echo -e "\n##### AOI #####\n"
			awk 'BEGIN{i=0}/cell \(AO.+\)/{i++;printf i"." " ";print $2}' $filename | sed 's/[()]//g' | column -x
			break
              		;;

          	"OAI") #OAI
			echo -e "\n##### OAI #####\n"
			awk 'BEGIN{i=0}/cell \(OA.+\)/{i++;printf i"." " ";print $2}' $filename | sed 's/[()]//g' | column -x
			break
              		;;
         	"Boolean Function") #BOOLEAN_FUNCTION
			echo -e "\n##### BOOLEAN FUNCTION #####\n"
			awk 'BEGIN{i=0}/cell \(DLY.+\)/{i++;printf i"." " ";print $2}' $filename | sed 's/[()]//g' | column -x
			break
              		;;

          	"Latch") #LATCH	
			echo -e "\n##### LATCH #####\n"
			awk 'BEGIN{i=0}/cell \(TLAT.+\)/{i++;printf i"." " ";print $2}' $filename | sed 's/[()]//g' | column -x
			break
             		;;

          	"Flip-Flop") #FLIP-FLOP
			echo -e "\n##### FLIP-FLOP #####\n"
			awk 'BEGIN{i=0}/cell \(.*FF.+\)/{i++;printf i"." " ";print $2}' $filename | sed 's/[()]//g' | column -x
			break
              		;;

          	"CLKGATE") #CLKGATE
			echo -e "\n##### CLKGATE #####\n"
			awk 'BEGIN{i=0}/cell \(CLK.+\)/{i++;printf i"." " ";print $2}' $filename | sed 's/[()]//g' | column -x
			break
              		;;

		"Main Menu") #Main menu
				main_menu
			;;

		"Exit")	end_time
			exit
			;;

		*)	echo "Invalid input,Please Select only from the list below and retry"
			no
			;;
	   esac
        done
}
check_cell_name_correct(){        #HERE_WHILE_LOOP_RUN_FOR_3_TIMES_AFTER_THIS_IT_WILL_GO_BACK_TO_THE_READ_CELL_INFORMATION()
				#HERE_WHILE_LOOP_GIVES_3_CHANCE_TO_ENTER_THE_CELL_NAME
					let i=1
					while [ $i -lt 4 ];do  
					read -p "Enter the Cell Name in UPPERCASE-" cell_name
					cell_list=$(egrep -o '^cell\s\(.+\)' $filename | awk '{print $2}' | sed 's/[()]//g')
					cell_count=$(echo "$cell_list" | egrep -w "$cell_name" | wc -l)
					
					if [[ $cell_count -ne 0 ]]; then
					 {
						sub_menu
						break
					   }
					else
					  {
						echo -e "\t\nINVALID CELL NAME\n"
					}
					fi
					let i=i+1
					done
					read_cell_information
}
read_cell_information(){
		read -p "Do you know the name the cell name?(y/n):" answer3
		echo
		while :
		do
		case "$answer3" in

			"y" | "Y")	check_cell_name_correct
					;;

			"n" | "N")	no
					check_cell_name_correct
					;;

			*)	echo "Invalid choice, please select either \"y\" or \"n\" only"
				read -p "Do you know the name the cell name?(y/n):" answer3
				echo
				;;
		esac
		done
}
sub_menu(){
		cell_information=$(sed -n "/cell ($cell_name)/,/^}/p" $filename)
		
			echo -e "\nTo select an option,type in it's serial number and press enter key"
			select answer2 in "Model" "Units" "Operating Condition" "Area" "Leakage Power" "Rail Connection" "Pin Information" "Timing" "Internal Power" "Whole Information" "Main Menu" "Exit";do

			case $answer2 in
			
			"Model")		model
						echo
						;;

			"Units")		units
						echo
						;;

			"Operating Condition")	operating_condition
						echo
						;;

			"Area")			area
						;;

			"Leakage Power")	leakage_power
						;;

			"Rail Connection")	rail
						;;

			"Pin Information")	pin		
						;;

			"Timing")		timing	
						;;

			"Internal Power")	internal_power	
						;;
						
			"Whole Information")	echo "$cell_information"
						;;

			"Main Menu")		main_menu
						;;
			
			"Exit")			#EMAIL_ONLY_SENT_IF_THESE_REGEX_FOUND_IN_REPORT.HTML_FILE
			sent=$(cat $"report.html"|egrep -w 'Model|Units|Operating Condition|Area|Leakage Power|Rail Connection'| wc -l)
						if [[ $sent -ne 0 ]];then
						  {
							choice
						     }
						else
						  {
							end_time
							exit
						     }
						fi
						;;

			*)			echo "Invalid input,Please Select only from the list below and retry"
						sub_menu
						;;
			esac
			done
}

printf "\n%s\n\n" "---------------------------------------------------------Script begins here---------------------------------------------"

#TO_REMOVE_THE_PREVIOUS_INFORMATION_FROM_REPORT.HTML_FILE
clear_previous_info=$(cat report.html > report.html)

#TO_DISPLAY_THE_START_TIME_AND_DATE
time=$(date +"%T")
DATE=$(date +%d/%b/%Y)
printf "%81s\n\n" "Start Time = "$time
start=$(date +%s)
echo "<!DOCTYPE html>
		<html>
		<head>
		<title>.lib_Report</title>
		</head>
		<body>
		<table width="290" >
		<tr>
		<td bgcolor="lightblue"><h4>Date- $DATE </h4><h4>Starting Time $time</h4></td>
		</tr>" >> report.html


main_menu(){
		echo -e "\nTo select an option,type in it's serial number and press enter key"

		select answer1 in "WORST CASE" "BEST CASE" "HELP" "EXIT"; do
		echo

			case $answer1 in 
					#WORST_CASE_OPTION_1
			"WORST CASE")	printf "\n%s\n\n" "-------------------------------------------------------------WORST CASE---------------------------------------------------"

					#TO_SHOW_WORST_CASE_ON_HTML_WEBPAGE
					echo "<table width="290" >
						<tr>
						<td bgcolor="#cc9900"><b><center>WORST CASE</center></b></td>
						</tr>
						</table>" >> report.html

						filename=slow.lib
						file_check
						read_cell_information
						;;

					#BEST_CASE_OPTION_2
			"BEST CASE")	printf "\n%s\n\n" "-------------------------------------------------------------BEST CASE----------------------------------------------------------------------"

					#TO_SHOW_BEST_CASE_ON_HTML_WEBPAGE
					echo "<br>
						<table width="290" >
						<tr>
						<td bgcolor="#cc9900"><b><center>BEST CASE</center></b></td>
						</tr>
						</table>
						" >> report.html
						
						filename=fast.lib
						file_check
						read_cell_information
						;;

					#HELP_OPTION_3
			"HELP")		Help
					main_menu
					;;

					#EXIT_OPTION_4	
			"EXIT")		end_time
					exit
					;;

			*)		echo "Invalid input,Please Select only from the list below and retry"
					main_menu
					;;
			esac
		done
}

end_time(){
		time="$(date +"%T")"
		printf "%81s\n\n" "End Time = "$time
		end=$(date +%s)
		dt=$(echo "$end - $start" | bc)
		dd=$(echo "$dt/86400" | bc)
		dt2=$(echo "$dt-86400*$dd" | bc)
		dh=$(echo "$dt2/3600" | bc)
		dt3=$(echo "$dt2-3600*$dh" | bc)
		dm=$(echo "$dt3/60" | bc)
		ds=$(echo "$dt3-60*$dm" | bc)
		printf "\n%s\n\n" "--------------------------------------------------------------Script ends here------------------------------------------"
		printf "%73s" "Total runtime:"
		printf "%02d:%02d:%02d\n" $dh $dm $ds
		echo "<table width="290" >
			<tr>	
			<td bgcolor="lightblue"><h4>End Time $time</h4><h4>Run Time "$dh:$dm:$ds"</h4></td>
			</tr>
			</table>		
			</body>
			</html>" >> report.html
}

main_menu
