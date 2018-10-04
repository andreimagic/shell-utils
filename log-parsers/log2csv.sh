#!/bin/bash
version="`echo -e "SCript by AndreiMagic, last revision 30.06.2017"`"

function speeding-report() {
    local csv="${unit_id}_speeding-report.csv"
    echo -e "Generating speeding report for unit ${unit_id} from ${file_path}\nwhere speed > ${speed_value} ..."
    echo "timestamp,unit id,gps coordinates,speed > ${speed_value}" > ${csv}
    for file in ${file_path} ; do
        echo "Processing file ${file} ..."
        grep "] #.*#131#${unit_id}#" ${file} | while read line; do
            local speed=$(echo ${line} | awk -F'#' '{print $13}')
            if (( $speed > $speed_value )); then
                local timestamp=$(echo ${line} | awk -F'#' '{print $12}')
                local id=$(echo ${line} | awk -F'#' '{print $11}')
                local gps=$(echo ${line} | awk -F'#' '{print $14","$15}')
                echo ${timestamp},${id},\"${gps}\",${speed} >> ${csv}
            fi
        done
    done
    echo -e "Finished generating $(pwd)/${csv}"
}

function history-report() {
    local csv="${unit_id}_history-report.csv"
    echo "Generating history report for unit ${unit_id} from ${file_path}"
    echo "timestamp,unit id,gps coordinates,speed" > ${csv}
    for file in ${file_path} ; do
        echo "Processing file ${file} ..."
        grep "] #.*#131#${unit_id}#" ${file} | while read line; do
            local timestamp=$(echo ${line} | awk -F'#' '{print $12}')
            local id=$(echo ${line} | awk -F'#' '{print $11}')
            local gps=$(echo ${line} | awk -F'#' '{print $14","$15}')
            local speed=$(echo ${line} | awk -F'#' '{print $13}')
            echo ${timestamp},${id},\"${gps}\",${speed} >> ${csv}
        done
    done
    echo -e "Finished generating $(pwd)/${csv}"
}

function list-ids() {
    if ${verbose}; then echo -e "Generating list of radio ids from ${file_path}"; fi
    IFS=$'\n' read -rd '' -a sorted_ids <<< "$(awk -F '#' '/] \#.+\#131\#/ {print $11}' ${file_path} | sort -n | uniq)"
    if ${verbose}; then echo -e "\nTotal elements: ${#sorted_ids[*]}"; fi
    echo ${sorted_ids[*]}
}

function kml() {
    local export_file="${unit_id}kml_$(date +%Y%m%d%H%M%S).kml"
    echo -e "<?xml version='1.0' encoding='UTF-8'?><kml xmlns='http://www.opengis.net/kml/2.2'>" > ${export_file}
    if [ -z ${unit_id} ]; then # generate for all unit ids found in the given file
        echo "Generating KML file for all units from ${file_path}"
        list-ids # this will generate the sorted_ids array
        for id in ${sorted_ids[*]}; do
            local gps=""
            for file in ${file_path} ; do
                echo "Processing unit id ${id} from file ${file_path} ..."
                gps+=$(grep "] #.*#131#${id}#" ${file} | awk -F'#' '{print $15","$14",0.0"}' | tr '\n' ' ')
            done
            echo -e "<Placemark><name>Poligon ${id}</name><styleUrl>#poly-000000-1-76-nodesc</styleUrl><ExtendedData></ExtendedData><Polygon><outerBoundaryIs><LinearRing><tessellate>1</tessellate><coordinates>${gps%?}</coordinates></LinearRing></outerBoundaryIs></Polygon></Placemark>" >> ${export_file}
        done
        echo -e "Finished generating $(pwd)/${export_file}"
        if ${verbose}; then echo -e "Total routes: ${#sorted_ids[*]}"; fi
    else # generate for a single given unit id
        echo "Generating KML file for unit ${unit_id} from ${file_path}"
        local gps=""
        for file in ${file_path} ; do
            echo "Processing unit id ${unit_id} from file ${file_path} ..."
            gps+=$(grep "] #.*#131#${unit_id}#" ${file} | awk -F'#' '{print $15","$14",0.0"}' | tr '\n' ' ')
        done
        echo -e "<Placemark><name>Poligon ${unit_id}</name><styleUrl>#poly-000000-1-76-nodesc</styleUrl><ExtendedData></ExtendedData><Polygon><outerBoundaryIs><LinearRing><tessellate>1</tessellate><coordinates>${gps%?}</coordinates></LinearRing></outerBoundaryIs></Polygon></Placemark>" >> ${export_file}
        echo -e "Finished generating $(pwd)/${export_file}"
    fi
    echo -e "</kml>" >> ${export_file}
}

function help() {
    echo -e "Useage: $0 option"
	echo -e "\n  Options are:"
    printf "%-60s%-30s\n" "  -l|--list -f|--file \"./logs/*.log\"" "# list all unique radio ids in the given log files"
    printf "%-60s%-30s\n" "  -h|--history -i|--id <radio id> -f|--file \"./logs/*.log\"" "# CSV history report for the given id"
    printf "%-60s%-30s\n" "  -s|--speeding -i|--id <radio id> -v|--value <speed limit value> -f|--file \"./logs/*.log\"" "# CSV speeding report for the given id or for all if the id is not given"
    printf "%-60s%-30s\n" "  -k|--kml -i|--id <radio id> -f|--file \"./logs/*.log\"" "# KML simulator routes for the given id"
    printf "%-60s%-30s\n" "  -h|--help" "# display this help message"
}



# MAIN
date
# if there are any valid arguments, parse and assign the values
if (( $# >= 2 )); then
    while [[ $# -gt 1 ]]; do
        key="$1"
        case $key in
            -i|--id)
                unit_id="$2"
                shift # past argument
                ;;
            -f|--file)
                file_path="$2"
                shift # past argument
                ;;
            -v|--value)
                speed_value="$2"
                shift # past argument
                ;;
            -s|--speeding)
                run="speeding-report"
                ;;
            -h|--history)
                run="history-report"
                ;;
            -k|--kml)
                run="kml"
                ;;
            -l|--list)
                run="list-ids"
                ;;
            -h|--help)
                help
                ;;
            *)
                echo -e "Incorrect syntax!"
                help
                exit 1
        esac
        shift # past argument or value
    done
    $run
elif (( $# == 0 )); then
	help
else
	echo -e "Incorrect syntax!"
    help
fi
