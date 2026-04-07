#!/bin/bash

if [ "$1" == "" ]
then
echo "Error: Please provide the name of Smart Contract under verification."
exit
fi
if [ ! "$2" ==  "bmc"  ] && [ ! "$2" ==  "chc"  ] ; 
then
echo " $2 Error: Please add 'bmc' or 'chc' checker"
exit
fi
 
if [ ! -f  "$1" ] && [ ! -d "$1" ];
then
echo "Error: No such file or directory"
exit
fi
echo "This code is developed by NITMinor Techlogies Pvt Limited"
total_assrt_cnt=0
total_assrt_cnt1=0
toatl_dynamic=0
total_uniq=0
Dres1=$(date +%s.%N)
if [ ! -d "Results" ]
then
mkdir Results
fi

if [ -d ./Results/$1-$2 ]
then
rm -rf  ./Results/$1-$2
fi

Assert_count=0
fl_count=0
error=0
if [ -f "$1" ]; then
if [[ "$1" == *.sol ]]; then
echo "============================================================"
echo "Processing Contract: $1"
echo "============================================================"
new_file=${1%.sol}
if [ -d ./Results/$new_file-$2 ]
then
rm -rf  ./Results/$new_file-$2
fi

mkdir ./Results/$new_file-$2

resultFile="${new_file}_output.txt"
cp "$1" "./Results/$new_file-$2"
outputfile="${new_file}_Final_Output.txt"; 
assertionInsertCount=`./.assertinserter ./Results/$new_file-$2/$1`

if [ "$2" == "bmc" ]
then
sol_comp=$( solc "./Results/$new_file-$2/$1" --model-checker-engine bmc --model-checker-targets assert  &> ./Results/$new_file-$2/$resultFile )	
sed -i 's/Warning: BMC:/CheckPoint\nWarning: BMC:/g' ./Results/$new_file-$2/$resultFile 

sed -n '/Warning: BMC: Assertion violation happens here./, /CheckPoint/p' ./Results/$new_file-$2/$resultFile &> ./Results/$new_file-$2/$outputfile 
fi
   
if [ "$2" == "chc" ]
then
#sol_comp=$( solc "./Results/$new_file-$2/$1" --model-checker-engine chc --model-checker-targets assert  &> ./Results/$new_file-$2/$resultFile )	
sol_comp=$( solc --model-checker-targets assert --model-checker-contracts "./Results/$new_file-$2/$1"  &> ./Results/$new_file-$2/$resultFile )	


sed -i 's/Warning: CHC:/CheckPoint\nWarning: CHC:/g' ./Results/$new_file-$2/$resultFile 



sed -n '/Warning: CHC: Assertion violation happens here./, /CheckPoint/p' ./Results/$new_file-$2/$resultFile &> ./Results/$new_file-$2/$outputfile 
fi

  
grep "assert(" ./Results/$new_file-$2/$outputfile > ./Results/$new_file-$2/.grep_result.txt

cut -d "|" -f 1 ./Results/$new_file-$2/.grep_result.txt > ./Results/$new_file-$2/.cut_result.txt 
sort -n -u ./Results/$new_file-$2/.cut_result.txt  > ./Results/$new_file-$2/.sort_result.txt
sort -n  ./Results/$new_file-$2/.grep_result.txt > ./Results/$new_file-$2/Dynamic_Assertions.txt
sort -n -u ./Results/$new_file-$2/Dynamic_Assertions.txt > ./Results/$new_file-$2/Unique_Assertions.txt
grep "assert" ./Results/$new_file-$2/$1  >./Results/$new_file-$2/Assertions_Insertesd.txt
dynamic=`wc -l < ./Results/$new_file-$2/.cut_result.txt`
uniq=`wc -l < ./Results/$new_file-$2/.sort_result.txt` 
let atomiccondition=$assertionInsertCount/2
if [[ $atomiccondition -gt 0 ]]; then
conditioncoverage=$(($uniq*100/$assertionInsertCount))
else
conditioncoverage=0
fi
echo "Properties inserted : ${assertionInsertCount}"
echo "Properties violation detected (dynamic) : ${dynamic}"
echo "Properties violation detected (unique) : ${uniq}"
echo "Total atomic condition : ${atomiccondition}"
echo "Condition Coverage % : ${conditioncoverage}%"

finalOutput="${new_file}_result.txt"
rm ./Results/$new_file-$2/.grep_result.txt
rm ./Results/$new_file-$2/.cut_result.txt
rm ./Results/$new_file-$2/.sort_result.txt

if [ -f ./Results/$new_file-$2/$finalOutput ]
then
rm ./Results/$new_file-$2/$finalOutput
fi
echo "Properties inserted : ${assertionInsertCount}" >> ./Results/$new_file-$2/$finalOutput
echo "Properties violation detected (dynamic) : ${dynamic}" >> ./Results/$new_file-$2/$finalOutput
echo "Properties violation detected (unique) : ${uniq}" >> ./Results/$new_file-$2/$finalOutput
echo "Total atomic condition : ${atomiccondition}" >> ./Results/$new_file-$2/$finalOutput
echo "Condition Coverage % : ${conditioncoverage}" >> ./Results/$new_file-$2/$finalOutput
Dres2=$(date +%s.%N)
dtD=$(echo "$Dres2 - $Dres1" | bc)
ddD=$(echo "$dtD/86400" | bc)
dtD2=$(echo "$dtD-86400*$ddD" | bc)
dhD=$(echo "$dtD2/3600" | bc)
dtD3=$(echo "$dtD2-3600*$dhD" | bc)
dmD=$(echo "$dtD3/60" | bc)
dsD=$(echo "$dtD3-60*$dmD" | bc)
echo "Total runtime in seconds" $dtD >> ./Results/$new_file-$2/$finalOutput
printf "Total runtime: %d:%02d:%02d:%02.4f\n" $ddD $dhD $dmD $dsD >> Results/$new_file-$2/$finalOutput
echo "Total runtime in seconds : $dtD "
echo "Total runtime:" $ddD:$dhD:$dmD:$dsD
echo 
exit
else 
    echo "Only Sol file will get compiled"
exit
fi
fi

############## Directory 
if [ ! -d ./Results/$1-$2 ]
then
mkdir ./Results/$1-$2
fi 
mkdir ./Results/$1-$2/mod_files
output_file="subfld.txt"
  > ./Results/$1-$2/subfld.txt
  > ./Results/$1-$2/temp.txt
  > ./Results/$1-$2/temp1.txt
c_file=$(pwd)
find "$c_file/$1" -maxdepth 1 -type f -name "*.sol" >> ./Results/$1-$2/subfld.txt
find "$c_file/$1" -mindepth 1 -type d | while read -r folder; do
echo "$folder" >> ./Results/$1-$2/subfld.txt
done 
while read -r line; do
if [[ "$line" == *.sol* ]]; then
file_name=$(echo "$line" | tr -d '\r')
if [[ -f "$line" ]]; then
f_name1=$(basename "$line")
sub_dir=${f_name1%.sol} 
if [ ! -d ./Results/$1-$2/$sub_dir ];   #Directory
then
mkdir ./Results/$1-$2/$sub_dir 
fi
cp "$line" "./Results/$1-$2/$sub_dir"
assertionInsertCount=`./.assertinserter ./Results/$1-$2/$sub_dir/$f_name1`
#echo Assert_count=$assertionInsertCount 
 cp "./Results/$1-$2/$sub_dir/$f_name1" "./Results/$1-$2/mod_files"
 echo "$c_file/Results/$1-$2/mod_files/$f_name1"  "$assertionInsertCount" >> ./Results/$1-$2/temp.txt
total_assrt_cnt=$(($total_assrt_cnt+$assertionInsertCount))
fl_count=$(( fl_count + 1 ))
fi 

else   
f_name=$(basename "$line")
if [ ! -d ./Results/$1-$2/$f_name ];   
then
mkdir ./Results/$1-$2/$f_name
fi
for contractFullPath in "$line"/*.sol; do
# Extract just the filename (e.g., "MyContract.sol")
contractFile=$(basename "$contractFullPath")
file_name=$(echo "$contractFile" | tr -d '\r')
ff_1="$line/$contractFile"
if [[ -f "$ff_1" ]]; then
dir_name=${contractFile%.sol}
if [ ! -d ./Results/$1-$2/$f_name/$dir_name ];   #Directory
then
mkdir ./Results/$1-$2/$f_name/$dir_name
fi    
cp "$ff_1" "./Results/$1-$2/$f_name/$dir_name"
assertionInsertCount=`./.assertinserter ./Results/$1-$2/$f_name/$dir_name/$contractFile`
cp "./Results/$1-$2/$f_name/$dir_name/$contractFile" "./Results/$1-$2/mod_files"
 # echo "Assert_count=$assertionInsertCount" 
#echo "$c_file/Results/$1/$f_name/$dir_name/$contractFile"     "$assertionInsertCount" >> ./Results/$1/temp1.txt
 echo "$c_file/Results/$1-$2/mod_files/$contractFile"     "$assertionInsertCount" >> ./Results/$1-$2/temp1.txt
total_assrt_cnt=$(($total_assrt_cnt+$assertionInsertCount))
fl_count1=$(( fl_count1 + 1 ))
fi
done 

  #######
if [ ! $fl_count1 = 0 ]; then 

while read -r line2; do
  read fld1 fld2 <<< $line2
     solc_chk=$(echo "$fld1" | tr -d '\r')
  # sol_comp=$(solc  "$field1" 2>&1)
   f_name3=$(basename "$solc_chk")
  echo "==================================================="
  echo "Processing Contract: $f_name/$f_name3"
  echo "==================================================="
  # sol_comp=$( solc ./Results/$1/$f_name2 2>&1 )
  echo "$fld2" 
  echo "==============" 
crt_dir=${f_name3%.sol}

#############
txt_file1="${crt_dir}_output.txt"
test="output.txt"
txt_file2="${crt_dir}_Final_Output.txt"
txt_file3="${crt_dir}_Dynamic_Assertions.txt"
txt_file4="${crt_dir}_Unique_Assertions.txt"
txt_file5="${crt_dir}_Assertions_Insertesd.txt"
outputfile="${crt_dir}_Final_Output.txt";
if [ "$2" == "bmc" ]
then  
sol_comp=$( solc "$fld1" --model-checker-engine bmc --model-checker-targets assert &> ./Results/$1-$2/$f_name/$crt_dir/$txt_file1)  
sed -i 's/Warning: BMC:/CheckPoint\nWarning: BMC:/g' ./Results/$1-$2/$f_name/$crt_dir/$txt_file1
grep -A 3 "$f_name3" ./Results/$1-$2/$f_name/$crt_dir/$txt_file1 &> ./Results/$1-$2/$f_name/$crt_dir/$outputfile
fi

if [ "$2" == "chc" ]
then  
sol_comp=$( solc "$fld1" --model-checker-engine chc --model-checker-targets assert &> ./Results/$1-$2/$f_name/$crt_dir/$txt_file1)  
sed -i 's/Warning: CHC:/CheckPoint\nWarning: CHC:/g' ./Results/$1-$2/$f_name/$crt_dir/$txt_file1
grep -A 3 "$f_name3" ./Results/$1-$2/$f_name/$crt_dir/$txt_file1 &> ./Results/$1-$2/$f_name/$crt_dir/$outputfile
fi

if grep -q "Error:" ./Results/$1-$2/$f_name/$crt_dir/$txt_file1; then
error=1
echo "./Results/$1-$2/$f_name/$crt_dir/$txt_file1" >> ./Results/$1-$2/Error_list.txt
> ./Results/$1-$2/$f_name/$crt_dir/.grep_result.txt
else
grep "assert(" ./Results/$1-$2/$f_name/$crt_dir/$outputfile  > ./Results/$1-$2/$f_name/$crt_dir/.grep_result.txt
fi
cut -d "|" -f 1 ./Results/$1-$2/$f_name/$crt_dir/.grep_result.txt > ./Results/$1-$2/$f_name/$crt_dir/.cut_result.txt 
sort -n -u ./Results/$1-$2/$f_name/$crt_dir/.cut_result.txt   > ./Results/$1-$2/$f_name/$crt_dir/.sort_result.txt
sort -n  ./Results/$1-$2/$f_name/$crt_dir/.grep_result.txt > ./Results/$1-$2/$f_name/$crt_dir/$txt_file3
sort -n -u ./Results/$1-$2/$f_name/$crt_dir/$txt_file3 > ./Results/$1-$2/$f_name/$crt_dir/$txt_file4
grep "assert" ./Results/$1-$2/$f_name/$crt_dir/$f_name3 > ./Results/$1-$2/$f_name/$crt_dir/$txt_file5

dynamic=`wc -l < ./Results/$1-$2/$f_name/$crt_dir/.cut_result.txt`
uniq=`wc -l < ./Results/$1-$2/$f_name/$crt_dir/.sort_result.txt` 
let atomiccondition=$fld2/2
if [[ $atomiccondition -gt 0 ]]; then
conditioncoverage=$(($uniq*100/$fld2))
else
conditioncoverage=0
fi
rm ./Results/$1-$2/$f_name/$crt_dir/.grep_result.txt
rm ./Results/$1-$2/$f_name/$crt_dir/.cut_result.txt
rm ./Results/$1-$2/$f_name/$crt_dir/.sort_result.txt
echo "Properties inserted : ${fld2}"
echo "Properties violation detected (dynamic) : ${dynamic}"
echo "Properties violation detected (unique) : ${uniq}"
echo "Total atomic condition : ${atomiccondition}"
echo "Condition Coverage % : ${conditioncoverage}%"
if [[ $error -gt 0 ]]; then
echo "Status: Contarct having errors: $error"
fi
total_dynamic=$(($total_dynamic+${dynamic}))
total_uniq=$(($total_uniq+${uniq}))

finalOutput="${crt_dir}_result.txt"

if [ -f ./Results/$1-$2/$f_name/$crt_dir/$finalOutput ]
then
rm ./Results/$1-$2/$f_name/$crt_dir/$finalOutput
fi

echo "Properties inserted : ${fld2}" >> ./Results/$1-$2/$f_name/$crt_dir/$finalOutput
echo "Properties violation detected (dynamic) : ${dynamic}" >> ./Results/$1-$2/$f_name/$crt_dir/$finalOutput
echo "Properties violation detected (unique) : ${uniq}" >> ./Results/$1-$2/$f_name/$crt_dir/$finalOutput
echo "Total atomic condition : ${atomiccondition}" >> ./Results/$1-$2/$f_name/$crt_dir/$finalOutput
echo "Condition Coverage % : ${conditioncoverage}" >> ./Results/$1-$2/$f_name/$crt_dir/$finalOutput

error=0

#############
 done < ./Results/$1-$2/temp1.txt
 > ./Results/$1-$2/temp1.txt
 fl_count1=0 
fi
fi
done < ./Results/$1-$2/subfld.txt 
if [ ! $fl_count = 0 ]; then 
while read -r line1; do
read field1 field2 <<< $line1
solc_chk=$(echo "$field1" | tr -d '\r')
  # sol_comp=$(solc  "$field1" 2>&1)erted : 48

   f_name2=$(basename "$solc_chk")
   txt_file=${f_name2%.sol} 

   #sol_comp=$(solc "$solc_chk")
  echo "==================================================="
  echo "Processing Contract: $f_name2"
  echo "==================================================="
  # sol_comp=$( solc ./Results/$1/$f_name2 2>&1 )
  

  echo "$field2" 
  echo "=============="
 # txt_file=${solc_chk%.sol} 
  txt_file1="${txt_file}_output.txt"
  test="output.txt"
  txt_file2="${txt_file}_Final_Output.txt"
  txt_file3="${txt_file}_Dynamic_Assertions.txt"    #chnage code with only dynmaic_assertion.txt no file name
  txt_file4="${txt_file}_Unique_Assertions.txt"
  txt_file5="${txt_file}_Assertions_Insertesd.txt"
  outputfile="${txt_file}_Final_Output.txt"; 
if [ "$2" == "bmc" ]
then  
sol_comp=$( solc "$field1" --model-checker-engine bmc  --model-checker-targets assert &> ./Results/$1-$2/$txt_file/$txt_file1)
sed -i 's/Warning: BMC:/CheckPoint\nWarning: BMC:/g' ./Results/$1-$2/$txt_file/$txt_file1
#sed -n '/Warning: BMC: Assertion violation happens here./, /CheckPoint/p' ./Results/$1/$txt_file/$txt_file1 &>  ./Results/$1/$txt_file/$outputfile
grep -A 4 "$f_name2" ./Results/$1-$2/$txt_file/$txt_file1 &>  ./Results/$1-$2/$txt_file/$outputfile
fi

if [ "$2" == "chc" ]
then  
sol_comp=$( solc "$field1" --model-checker-engine chc  --model-checker-targets assert &> ./Results/$1-$2/$txt_file/$txt_file1)
sed -i 's/Warning: CHC:/CheckPoint\nWarning: CHC:/g' ./Results/$1-$2/$txt_file/$txt_file1
#sed -n '/Warning: CHC: Assertion violation happens here./, /CheckPoint/p' ./Results/$1/$txt_file/$txt_file1 &>  ./Results/$1/$txt_file/$outputfile
grep -A 4 "$f_name2" ./Results/$1-$2/$txt_file/$txt_file1 &>  ./Results/$1-$2/$txt_file/$outputfile
fi

if  grep  -q "Error:" ./Results/$1-$2/$txt_file/$txt_file1 ; then
error=1
echo "./Results/$1-$2/$f_name/$crt_dir/$txt_file1" >> ./Results/$1-$2/Error_list.txt
 > ./Results/$1-$2/$txt_file/.grep_result.txt
else
grep "assert(" ./Results/$1-$2/$txt_file/$outputfile  > ./Results/$1-$2/$txt_file/.grep_result.txt
fi
cut -d "|" -f 1 ./Results/$1-$2/$txt_file/.grep_result.txt > ./Results/$1-$2/$txt_file/.cut_result.txt 
sort -n -u ./Results/$1-$2/$txt_file/.cut_result.txt   > ./Results/$1-$2/$txt_file/.sort_result.txt
sort -n  ./Results/$1-$2/$txt_file/.grep_result.txt > ./Results/$1-$2/$txt_file/$txt_file3
sort -n -u ./Results/$1-$2/$txt_file/$txt_file3 > ./Results/$1-$2/$txt_file/$txt_file4
grep "assert" ./Results/$1-$2/$txt_file/$f_name2 > ./Results/$1-$2/$txt_file/$txt_file5

dynamic=`wc -l < ./Results/$1-$2/$txt_file/.cut_result.txt`
uniq=`wc -l < ./Results/$1-$2/$txt_file/.sort_result.txt` 
let atomiccondition=$field2/2
if [[ $atomiccondition -gt 0 ]]; then
conditioncoverage=$(($uniq*100/$field2))
else
conditioncoverage=0
fi
rm ./Results/$1-$2/$txt_file/.grep_result.txt
rm ./Results/$1-$2/$txt_file/.cut_result.txt
rm ./Results/$1-$2/$txt_file/.sort_result.txt
echo "Properties inserted : ${field2}"
echo "Properties violation detected (dynamic) : ${dynamic}"
echo "Properties violation detected (unique) : ${uniq}"
echo "Total atomic condition : ${atomiccondition}"
echo "Condition Coverage % : ${conditioncoverage}%"
if [[ $error -gt 0 ]]; then
echo "Status: Contarct having errors1 : $error"
fi
total_dynamic=$(($total_dynamic+${dynamic}))
total_uniq=$(($total_uniq+${uniq}))

finalOutput="${txt_file}_result.txt"

if [ -f ./Results/$1-$2/$txt_file/$finalOutput ]
then
rm ./Results/$1-$2/$txt_file/$finalOutput
fi
echo "Properties inserted : ${field2}" >> ./Results/$1-$2/$txt_file/$finalOutput
echo "Properties violation detected (dynamic) : ${dynamic}" >> ./Results/$1-$2/$txt_file/$finalOutput
echo "Properties violation detected (unique) : ${uniq}" >> ./Results/$1-$2/$txt_file/$finalOutput
echo "Total atomic condition : ${atomiccondition}" >> ./Results/$1-$2/$txt_file/$finalOutput
echo "Condition Coverage % : ${conditioncoverage}" >> ./Results/$1-$2/$txt_file/$finalOutput
error=0
 done < ./Results/$1-$2/temp.txt
fl_count=0
fi
total_atmcond=0
let total_atmcond=$total_assrt_cnt/2
if [[ $total_atmcond -gt 0 ]]; then
total_cndcvg=$(echo "$total_uniq*100/$total_assrt_cnt" | bc)
else
conditioncoverage=0
fi

echo "Properties inserted : ${total_assrt_cnt}" >> ./Results/$1-$2/Final_result.txt
echo "Properties violation detected (dynamic) : ${total_dynamic}" >> ./Results/$1-$2/Final_result.txt
echo "Properties violation detected (unique) : ${total_uniq}" >> ./Results/$1-$2/Final_result.txt
echo "Total atomic condition : ${total_atmcond}" >> ./Results/$1-$2/Final_result.txt
echo "Condition Coverage % : ${total_cndcvg}" >> ./Results/$1-$2/Final_result.txt

Dres2=$(date +%s.%N)
dtD=$(echo "$Dres2 - $Dres1" | bc)
ddD=$(echo "$dtD/86400" | bc)
dtD2=$(echo "$dtD-86400*$ddD" | bc)
dhD=$(echo "$dtD2/3600" | bc)
dtD3=$(echo "$dtD2-3600*$dhD" | bc)
dmD=$(echo "$dtD3/60" | bc)
dsD=$(echo "$dtD3-60*$dmD" | bc)
echo "Total runtime in seconds" $dtD >> ./Results/$1-$2/Final_result.txt
printf "Total runtime: %d:%02d:%02d:%02.4f\n" $ddD $dhD $dmD $dsD >> ./Results/$1-$2/Final_result.txt

echo "===================================================" 
echo "Final result of the $1 Project"
echo "==================================================="
echo " $1 Project total Assert count: $total_assrt_cnt" 
echo " $1 Project total Properties violation detected (dynamic): $total_dynamic"
echo " $1 Project total violation detected (unique): $total_uniq"
echo " $1 Project total atomic condition: $total_atmcond"
echo " $1 Project total Condition Coverage % : ${total_cndcvg}% "
echo "****************Time Analysis****************"
echo " $1 Project total runtime in seconds : $dtD "
echo " $1 Project total runtime:" $ddD:$dhD:$dmD:$dsD
echo "==================================================="
rm ./Results/$1-$2/temp.txt
rm ./Results/$1-$2/temp1.txt
