#! /bin/bash

###########################################################
# SRS SIM928 battery EEPROM tool
###########################################################
# Convenient functions for reading and writing the EEPROM
# of the battery of an SRS SIM928 battery pack
###########################################################
# V 1.0
###########################################################
# F. Forster
###########################################################

hash i2cset 2>/dev/null || { echo >&2 "i2cset not installed.  Aborting."; exit 1; }
hash i2cget 2>/dev/null || { echo >&2 "i2cget not installed.  Aborting."; exit 1; }

echo 'Please enter the bus to use [1]:'
read bus

if [ -z "$bus" ]; then
	bus=1
fi

echo 'Please enter the address of data register 1 [0x50]:'
read data_reg_1

if [ -z "$data_reg_1" ]; then
	data_reg_1=0x50
fi

echo 'Please enter the address of data register 2 [0x51]:'
read data_reg_2

if [ -z "$data_reg_2" ]; then
	data_reg_2=0x51
fi

echo 'Please enter the address of data register 3 [0x52]:'
read data_reg_3

if [ -z "$data_reg_3" ]; then
        data_reg_3=0x52
fi

echo 'Please enter the operation to perform, [r]ead or [w]rite [r]:'
read action

if [ -z "$action" ]; then
	action='r'
fi

function print_line {
        printf -v line '+%*s+' "$(($1 * 5 + 4))"
        echo ${line// /-}
}

function print_array_table {
        name=$1[@]
        a=("${!name}")
	len=$(( ${#a[@]} - 1))
        print_line $len
	printf '|'
        len_seq=`seq 0 $len`
        for i in $len_seq; do
                printf '%4s|' "$i"
        done
        printf '\n'
        print_line $len
        printf '|'
	
        printf -- '%s|' "${a[@]}"
        printf '\n'
        print_line $len
        printf '|'
        for (( count=0; count<=$(( ($len - 1) /2)); count++ )); do
                v1=${a[$(( 2* $count ))]}
                v2=${a[$(( 2* $count + 1 ))]}
                v=$((v1 * (0xFF + 1) + v2))
                printf '%9s|' $v
        done
        printf '\n'
        print_line $len
	savearray=()
	for i in "${a[@]}"; do
		savearray+=("${i:1}")
	done
	echo -ne $(printf "\\\\%s" "${savearray[@]}") > $1.dump
	echo -e "Exported to $1.dump \n\n"

}

function get_h_byte {
	let "h_byte=$1 >> 8 & 255"
	echo $h_byte
}

function get_l_byte {
	let "l_byte=$1 & 255"
	echo $l_byte
}

function set_date {
	year=`date +%Y`
	month=`date +%m`
	day=`date +%d`
	echo Setting date to $day/$month/$year
	echo Is that okay [y]/n?
	read ok
        re='^[0-9]+$'
	if [[ $ok = [nN] ]]; then
		day=32
		while [ $day -gt 31 ]; do
			echo Enter day
			read day
                        case $day in
                                ''|*[!0-9]*) day=32 ;;
                        esac
		done
		month=13
		while [ $month -gt 12 ]; do
			echo Enter month
			read month
                        case $month in
                                ''|*[!0-9]*) month=13 ;;
                        esac
		done
		ok=0
                echo Enter year
		while [ $ok = 0 ]; do
			read year
			case $year in
    				''|*[!0-9]*) ok=0 ;;
				*) ok=1 ;;
			esac
		done
	fi

	`i2cset -y $bus $data_reg_1 0x04 $(get_h_byte $month)`
	`i2cset -y $bus $data_reg_1 0x05 $(get_l_byte $month)`
	`i2cset -y $bus $data_reg_1 0x06 $(get_h_byte $day)`
	`i2cset -y $bus $data_reg_1 0x07 $(get_l_byte $day)`
	`i2cset -y $bus $data_reg_1 0x08 $(get_h_byte $year)`
	`i2cset -y $bus $data_reg_1 0x09 $(get_l_byte $year)`			
}

function set_u_min {
	echo 'Enter minimum discharge voltage in mV:'
	ok=0
	while [ $ok -eq 0 ]; do
                        read value 
                        case $value in
                                ''|*[!0-9]*) ok=0 ;;
                                *) ok=1 ;;
                        esac
	done
        `i2cset -y $bus $data_reg_1 0x0e $(get_h_byte $value)`
        `i2cset -y $bus $data_reg_1 0x0f $(get_l_byte $value)`
}

function set_u_max {
	echo 'Enter voltage in charged state in mV':
	ok=0
        while [ $ok -eq 0 ]; do
                        read value
                        case $value in
                                ''|*[!0-9]*) ok=0 ;;
                                *) ok=1 ;;
                        esac
        done
        `i2cset -y $bus $data_reg_1 0x10 $(get_h_byte $value)`
        `i2cset -y $bus $data_reg_1 0x11 $(get_l_byte $value)`

}

function set_c {
	echo 'Enter batteries capacitance-45 in mAh:'
	ok=0
        while [ $ok -eq 0 ]; do
                        read value
                        case $value in
                                ''|*[!0-9]*) ok=0 ;;
                                *) ok=1 ;;
                        esac
        done
        `i2cset -y $bus $data_reg_1 0x12 $(get_h_byte $value)`
        `i2cset -y $bus $data_reg_1 0x13 $(get_l_byte $value)`

}

function set_maxcycles {
	echo 'Enter batteries maximum recharge cycles:'
	ok=0
        while [ $ok -eq 0 ]; do
                        read value
                        case $value in
                                ''|*[!0-9]*) ok=0 ;;
                                *) ok=1 ;;
                        esac
        done
        `i2cset -y $bus $data_reg_1 0x14 $(get_h_byte $value)`
        `i2cset -y $bus $data_reg_1 0x15 $(get_l_byte $value)`

}

function reset_cycles {
	echo 'Resetting cycles'
	value=1
        `i2cset -y $bus $data_reg_2 0x02 $(get_h_byte $value)`
        `i2cset -y $bus $data_reg_2 0x03 $(get_l_byte $value)`
        `i2cset -y $bus $data_reg_2 0x04 $(get_h_byte $value)`
        `i2cset -y $bus $data_reg_2 0x05 $(get_l_byte $value)`
        `i2cset -y $bus $data_reg_2 0x06 $(get_h_byte $value)`
        `i2cset -y $bus $data_reg_2 0x07 $(get_l_byte $value)`
        `i2cset -y $bus $data_reg_2 0x08 $(get_h_byte $value)`
        `i2cset -y $bus $data_reg_2 0x09 $(get_l_byte $value)`
}

if [ $action = 'r' ]; then
	printf 'Data register 1\n'
	len=21
	len_seq=`seq 0 $len`
	for i in $len_seq; do
                data_1[$i]=`i2cget -y $bus $data_reg_1 $i`
        done   
	print_array_table data_1
	
	printf 'Data register 2\n'
	len=11
        len_seq=`seq 0 $len`
        for i in $len_seq; do
                data_2[$i]=`i2cget -y $bus $data_reg_2 $i`
        done
        print_array_table data_2
        printf 'Data register 3\n'
        len=1
        len_seq=`seq 0 $len`
        for i in $len_seq; do
                data_3[$i]=`i2cget -y $bus $data_reg_3 $i`
        done
        print_array_table data_3

	
	

elif [ $action = 'w' ]; then
	action=100
	while [ $action -ne 0 ]; do
		printf "Choose what to do: \n"
		printf "[0] Exit\n"
		printf "[1] Set date to today's date\n"
		printf "[2] Set minimum discharge voltage\n"
		printf "[3] Set voltage in charged state\n"
		printf "[4] Set batteries' capacitance\n"
		printf "[5] Set batteries' maximum recharge cycles\n"
		printf "[6] Reset information about battery charge cycles\n"
		read action
		case $action in 
			*[!0-9]*) action=0 ;; 
			[!0-6]) action=100 ;;
			1) set_date ;;
			2) set_u_min ;;
			3) set_u_max ;;
			4) set_c ;;
			5) set_maxcycles ;;
			6) reset_cycles ;;
		
		esac

	done
else
	echo >&2 'Unknown operation'
	exit 1
fi

