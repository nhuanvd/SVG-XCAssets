#!/bin/bash
check_empty() {
    # 0 = true
    # 1 = false
    if [ ! -z "$1" -a "$1" != "" ]; then
        return 1
    fi
    return 0
}

check_number() {
    # 0 = true
    # 1 = false
    re='^[0-9]+$'
    if ! [[ $1 =~ $re ]] ; then
        return 1
    fi
    return 0
}

check_command_exist(){
    result="$(command -v $1)"
    return $(! check_empty $result)
}

process_svg_to_png() {
    local ip_source_folder="$1"
    local ip_source_name="$2"
    local ip_xcassets_folder="$3"

    local image_width="$4"
    local image_height="$5"
    local group="$6"

    # remove .svg extension
    ip_source_name=${ip_source_name%.svg}

    # Source file full path
    source_file_full=$ip_source_folder'/'$ip_source_name'.svg'

    # Image file path
    image_name=$group'_'$ip_source_name
    image_name=${image_name#_} #Remove _ prefix if group is empty

    image_file_path=$ip_xcassets_folder'/'$image_name'.imageset'

    # Make Image folder if not exist
    mkdir -p $image_file_path
    
    echo 'Procesing file '$source_file_full

    # 1x 2x 3x images
    for i in 1 2 3
    do
        image_file_full=$image_file_path'/'$image_name'@'$i'x.png'
        width=$(($i*$image_width))
        height=$(($i*$image_height))
        log=$(inkscape --without-gui --export-dpi=72 --export-width=$width --export-height=$height --export-png=$image_file_full $source_file_full)
    done
    
    # Contents.json data
    json_data='{
                "images" : [
                    {
                        "idiom" : "universal",
                        "filename" : "'$image_name'@1x.png",
                        "scale" : "1x"
                    },
                    {
                        "idiom" : "universal",
                        "filename" : "'$image_name'@2x.png",
                        "scale" : "2x"
                    },
                    {
                        "idiom" : "universal",
                        "filename" : "'$image_name'@3x.png",
                        "scale" : "3x"
                    }
                ],
                "info" : {
                    "version" : 1,
                    "author" : "xcode"
                }
            }'
    # Use python write json with pretty format indent = 2
    echo $json_data | python -c 'import json,sys; obj=json.load(sys.stdin); print json.dumps(obj, indent=2);' > $image_file_path'/Contents.json' 
}

process_all_svg_in_folder_with_same_size() {
    local ip_source_folder="$1"
    local ip_xcassets_folder="$2"

    local image_width="$3"
    local image_height="$4"
    local group="$5"

    for file in $ip_source_folder'/'*; do
        source_name=${file##*/}
        if [[ "$source_name" == *.svg ]]
        then
          process_svg_to_png $ip_source_folder $source_name $ip_xcassets_folder $image_width $image_height $group
        fi
    done
}

show_help() {
    echo 'Command line tool to make xcode assets image from SVG'
    echo 'Version 0.1.0'
    echo 'Copyright 2016 by @Nhuanvd'
    echo 'https://github.com/nhuanvd'
    echo ''
    echo 'Usage:'
    echo '  ./svg_xcassets.sh --source=./flags --name=vn --xcassets=./Assets.xcassets --width=100 --height=100 --group=flag'
    echo '  ./svg_xcassets.sh --all --source=./flags --xcassets=./Assets.xcassets --width=100 --height=100'
    echo ''
    echo 'Flags:'
    echo '  -h, --help     Display this help'
    echo '  --all          Convert all svg in source folder (optional)'
    echo '  --source       Source folder (required)'
    echo '  --name         Name of svg inage (required if all flag not set)'
    echo '  --xcassets     Image.xcassets folder (required)'
    echo '  --width        Width of output image (required)' 
    echo '  --height       Height of output image (required)' 
    echo '  --group        Output name prefix (optional)'
}

if (! check_command_exist 'inkscape'); then
    echo 'inkscape not found'
    echo 'Install inkscape on your Mac by using command `brew install homebrew/x11/inkscape`'
    exit 0
fi

if (! check_command_exist 'python'); then
    echo 'python not found'
    echo 'Install python on your Mac by using command `brew install python`'
    exit 0
fi

# Capture arguments
_single_image=0 # 0 = true
_source_folder=''
_source_name=''
_group=''
_xcassets_folder=''
_image_width=''
_image_height=''
for i in "$@"
do
    case $i in
        -h|--help)
        show_help
        exit 0
        ;;
        -all|--all)
        _single_image=1 # 1 = false
        ;;
        --source=*)
        _source_folder="${i#*=}"
        ;;
        --name=*)
        _source_name="${i#*=}"
        ;;
        --xcassets=*)
        _xcassets_folder="${i#*=}"
        ;;
        --group=*)
        _group="${i#*=}"
        ;;
        --width=*)
        _image_width="${i#*=}"
        ;;
        --height=*)
        _image_height="${i#*=}"
        ;;
    esac
done

# Check arguments
if (check_empty $_source_folder || 
    check_empty $_xcassets_folder ||
    (check_empty $_source_name && [ ${_single_image} -eq 0 ]) || # Miss source name for single image mode
    $(! check_number $_image_width) ||
    $(! check_number $_image_height))
then
    show_help
    exit 0
fi

# Process
if [ ${_single_image} -eq 0 ]; then
    # Single image
    process_svg_to_png $_source_folder $_source_name $_xcassets_folder $_image_width $_image_height $_group
else
    # All in folder
    process_all_svg_in_folder_with_same_size $_source_folder $_xcassets_folder $_image_width $_image_height $_group
fi

