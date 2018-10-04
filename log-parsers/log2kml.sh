#!/bin/bash

function kml() {
    local export_file="${unit_id}_kml_$(date +%Y%m%d%H%M%S).kml"
    
    xml_header="<?xml version=\"1.0\" encoding=\"utf-8\"?>
                    <kml 
                        xmlns=\"http://www.opengis.net/kml/2.2\" 
                        xmlns:gx=\"http://www.google.com/kml/ext/2.2\" 
                        xmlns:kml=\"http://www.opengis.net/kml/2.2\">
                        <Document>
                            <name>Site Survey: ${unit_id} - ${file_path}</name>
                            <open>1</open>
                            <StyleMap id=\"msn_triangle\">
                                <Pair>
                                    <key>normal</key>
                                    <styleUrl>#sn_triangle</styleUrl>
                                </Pair>
                                <Pair>
                                    <key>highlight</key>
                                    <styleUrl>#sh_triangle</styleUrl>
                                </Pair>
                            </StyleMap>
                            <StyleMap id=\"msn_target0\">
                                <Pair>
                                    <key>normal</key>
                                    <styleUrl>#sn_target0</styleUrl>
                                </Pair>
                                <Pair>
                                    <key>highlight</key>
                                    <styleUrl>#sh_target0</styleUrl>
                                </Pair>
                            </StyleMap>
                            <StyleMap id=\"msn_target1\">
                                <Pair>
                                    <key>normal</key>
                                    <styleUrl>#sn_target1</styleUrl>
                                </Pair>
                                <Pair>
                                    <key>highlight</key>
                                    <styleUrl>#sh_target1</styleUrl>
                                </Pair>
                            </StyleMap>
                            <StyleMap id=\"msn_target2\">
                                <Pair>
                                    <key>normal</key>
                                    <styleUrl>#sn_target2</styleUrl>
                                </Pair>
                                <Pair>
                                    <key>highlight</key>
                                    <styleUrl>#sh_target2</styleUrl>
                                </Pair>
                            </StyleMap>
                            <StyleMap id=\"msn_target3\">
                                <Pair>
                                    <key>normal</key>
                                    <styleUrl>#sn_target3</styleUrl>
                                </Pair>
                                <Pair>
                                    <key>highlight</key>
                                    <styleUrl>#sh_target3</styleUrl>
                                </Pair>
                            </StyleMap>
                            <StyleMap id=\"msn_target4\">
                                <Pair>
                                    <key>normal</key>
                                    <styleUrl>#sn_target4</styleUrl>
                                </Pair>
                                <Pair>
                                    <key>highlight</key>
                                    <styleUrl>#sh_target4</styleUrl>
                                </Pair>
                            </StyleMap>
                            <Style id=\"sn_triangle\">
                                <IconStyle>
                                    <scale>1.1</scale>
                                    <Icon>
                                        <href>https://chart.googleapis.com/chart?chst=d_simple_text_icon_left&amp;chld=|14|000|camping|24|FF0000|a00</href>
                                    </Icon>
                                </IconStyle>
                            </Style>
                            <Style id=\"sh_triangle\">
                                <IconStyle>
                                    <scale>1.3</scale>
                                    <Icon>
                                        <href>https://chart.googleapis.com/chart?chst=d_simple_text_icon_left&amp;chld=|14|000|camping|24|FF0000|a00</href>
                                    </Icon>
                                </IconStyle>
                            </Style>
                            <Style id=\"sn_target0\">
                                <IconStyle>
                                    <scale>1.1</scale>
                                    <Icon>
                                        <href>https://chart.googleapis.com/chart?chst=d_simple_text_icon_left&amp;chld=|14|000|glyphish_target|24|FF0000</href>
                                    </Icon>
                                </IconStyle>
                            </Style>
                            <Style id=\"sh_target0\">
                                <IconStyle>
                                    <scale>1.3</scale>
                                    <Icon>
                                        <href>https://chart.googleapis.com/chart?chst=d_simple_text_icon_left&amp;chld=|14|000|glyphish_target|24|FF0000</href>
                                    </Icon>
                                </IconStyle>
                            </Style>
                            <Style id=\"sn_target1\">
                                <IconStyle>
                                    <scale>1.1</scale>
                                    <Icon>
                                        <href>https://chart.googleapis.com/chart?chst=d_simple_text_icon_left&amp;chld=|14|000|glyphish_target|24|FF8000</href>
                                    </Icon>
                                </IconStyle>
                            </Style>
                            <Style id=\"sh_target1\">
                                <IconStyle>
                                    <scale>1.3</scale>
                                    <Icon>
                                        <href>https://chart.googleapis.com/chart?chst=d_simple_text_icon_left&amp;chld=|14|000|glyphish_target|24|FF8000</href>
                                    </Icon>
                                </IconStyle>
                            </Style>
                            <Style id=\"sn_target2\">
                                <IconStyle>
                                    <scale>1.1</scale>
                                    <Icon>
                                        <href>https://chart.googleapis.com/chart?chst=d_simple_text_icon_left&amp;chld=|14|000|glyphish_target|24|FFFF00</href>
                                    </Icon>
                                </IconStyle>
                            </Style>
                            <Style id=\"sh_target2\">
                                <IconStyle>
                                    <scale>1.3</scale>
                                    <Icon>
                                        <href>https://chart.googleapis.com/chart?chst=d_simple_text_icon_left&amp;chld=|14|000|glyphish_target|24|FFFF00</href>
                                    </Icon>
                                </IconStyle>
                            </Style>
                            <Style id=\"sn_target3\">
                                <IconStyle>
                                    <scale>1.1</scale>
                                    <Icon>
                                        <href>https://chart.googleapis.com/chart?chst=d_simple_text_icon_left&amp;chld=|14|000|glyphish_target|24|00FF00</href>
                                    </Icon>
                                </IconStyle>
                            </Style>
                            <Style id=\"sh_target3\">
                                <IconStyle>
                                    <scale>1.3</scale>
                                    <Icon>
                                        <href>https://chart.googleapis.com/chart?chst=d_simple_text_icon_left&amp;chld=|14|000|glyphish_target|24|00FF00</href>
                                    </Icon>
                                </IconStyle>
                            </Style>
                            <Style id=\"sn_target4\">
                                <IconStyle>
                                    <scale>1.1</scale>
                                    <Icon>
                                        <href>https://chart.googleapis.com/chart?chst=d_simple_text_icon_left&amp;chld=|14|000|glyphish_target|24|0000FF</href>
                                    </Icon>
                                </IconStyle>
                            </Style>
                            <Style id=\"sh_target4\">
                                <IconStyle>
                                    <scale>1.3</scale>
                                    <Icon>
                                        <href>https://chart.googleapis.com/chart?chst=d_simple_text_icon_left&amp;chld=|14|000|glyphish_target|24|0000FF</href>
                                    </Icon>
                                </IconStyle>
                            </Style>
                            <Style id=\"IN_VEHICLE\">
                                <IconStyle>
                                    <scale>1</scale>
                                    <color>ff00aaff</color>
                                    <Icon>
                                        <href>http://maps.google.com/mapfiles/kml/shapes/cabs.png</href>
                                    </Icon>
                                </IconStyle>
                            </Style>
                            <Style id=\"ON_BICYCLE\">
                                <IconStyle>
                                    <scale>1</scale>
                                    <color>ff00aaff</color>
                                    <Icon>
                                        <href>http://maps.google.com/mapfiles/kml/shapes/cycling.png</href>
                                    </Icon>
                                </IconStyle>
                            </Style>
                            <Style id=\"ON_FOOT\">
                                <IconStyle>
                                    <scale>1</scale>
                                    <color>ff00aaff</color>
                                    <Icon>
                                        <href>http://maps.google.com/mapfiles/kml/shapes/hiker.png</href>
                                    </Icon>
                                </IconStyle>
                            </Style>
                            <Style id=\"STILL\">
                                <IconStyle>
                                    <scale>1</scale>
                                    <color>ff00aaff</color>
                                    <Icon>
                                        <href>http://maps.google.com/mapfiles/kml/shapes/parking_lot.png</href>
                                    </Icon>
                                </IconStyle>
                            </Style>
                            <Style id=\"UNKNOWN\">
                                <IconStyle>
                                    <scale>1</scale>
                                    <color>ff00aaff</color>
                                    <Icon>
                                        <href>http://maps.google.com/mapfiles/kml/shapes/info_circle.png</href>
                                    </Icon>
                                </IconStyle>
                            </Style>"
    xml_footer="</Document></kml>"

    echo -e $xml_header > ${export_file}
    
    if [ -z ${unit_id} ]; then # generate for all unit ids found in the given file
        echo "Please enter a valid unit id"
        help
    else # generate for a single given unit id
        echo "Generating KML file for unit ${unit_id} from ${file_path}"
        echo -e "<Folder><name>${unit_id}</name><open>0</open>" >> ${export_file}
        for file in ${file_path} ; do
            echo "Processing unit id ${unit_id} from file ${file} ..."

            # if [[ $(grep "accuracy" ${file} | grep  ${unit_id} | head -n 1 | cut -d'"' -f25) == accuracy* ]]; then echo OK; else echo NOK; fi
            grep "accuracy" ${file} | grep ${unit_id} | while read -r line; do
                if [[ $(echo ${line} | cut -d'"' -f25) == accuracy* ]]; then
                    local time=$(echo ${line} | cut -d':' -f1,2)
                    local timestamp=$(echo ${line} | cut -d':' -f10 | cut -d',' -f1)
                    local speed=$(echo ${line} | cut -d':' -f11 | cut -d ',' -f1)
                    local lat=$(echo ${line} | cut -d':' -f12 | cut -d ',' -f1)
                    local lon=$(echo ${line} | cut -d':' -f13 | cut -d ',' -f1)
                    local accuracy=$(echo ${line} | cut -d':' -f14 | cut -d '\' -f1 | cut -d ',' -f1)
                    local activity=$(echo ${line} | cut -d':' -f15 | cut -d'"' -f2 | cut -d'\' -f1)
                    local activity_confidence=$(echo ${line} | cut -d':' -f16 | cut -d '\' -f1)
                    echo -e "${time} | ${accuracy} | ${lat},${lon},${speed} | ${activity},${activity_confidence}"
                elif [[ $(echo ${line} | cut -d'"' -f23) == accuracy* ]]; then
                    local time=$(echo ${line} | cut -d':' -f1,2)
                    local timestamp=$(echo ${line} | cut -d':' -f11 | cut -d',' -f1)
                    local speed=$(echo ${line} | cut -d':' -f8 | cut -d ',' -f1)
                    local lat=$(echo ${line} | cut -d':' -f14 | cut -d',' -f1 | cut -d'\' -f1)
                    local lon=$(echo ${line} | cut -d':' -f10 | cut -d ',' -f1)
                    local accuracy=$(echo ${line} | cut -d':' -f13 | cut -d ',' -f1)
                    echo -e "${time} | ${accuracy} | ${lat},${lon},${speed}"
                else
                    echo "Fail to parse file ${file} for ID ${unit_id}"
                    rm -f ${export_file}
                    exit 1
                fi
                echo -e "<Placemark><name>${time}</name><description>Accuracy: ${accuracy} m&lt;br /&gt;Latitude: ${lat}&lt;br /&gt;Longitude: ${lon}&lt;br /&gt;Speed: ${speed} kmh&lt;br /&gt;Activity: ${activity}&lt;br /&gt;Activity confidence: ${activity_confidence}&lt;br /&gt;Timestamp: ${timestamp}&lt;br /&gt;</description><styleUrl>#${activity}</styleUrl><Point><coordinates>${lon},${lat},${speed}</coordinates></Point></Placemark>" >> ${export_file}
            done
            echo -e "</Folder>" >> ${export_file}
        done
        echo -e $xml_footer >> ${export_file}
        echo -e "Finished generating $(pwd)/${export_file}"
    fi
}



function help() {
    echo -e "Useage: $0 option"
	echo -e "\n  Options are:"
    printf "%-60s%-30s\n" "  -i|--id <radio id> -f|--file \"./logs/*.log\"" "# KML simulator routes for the given id"
    printf "%-60s%-30s\n" "  -h|--help" "# display this help message"
}

# MAIN
date
# if there are any valid arguments, parse and assign the values
if (( $# >= 2 )); then
    while [[ $# -gt 1 ]]; do
        key="$1"
        # echo Parsed key: $key
        case $key in
            -i|--id)
                unit_id="$2"
                shift # past argument
                ;;
            -f|--file)
                file_path="$2"
                shift # past argument
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
    run="kml"
    $run
elif (( $# == 0 )); then
	help
else
	echo -e "Incorrect syntax!"
    help
fi
