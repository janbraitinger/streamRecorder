#!/bin/bash

url=rtmp://134.60.30.44/live
folder=video_data/pre
mkdir -p $folder
mkdir -p video_data/config
path=$folder
interval=10
waitAfterError=10
_oneFlag=true
_recordFlag=false
touch video_data/status.txt
echo "offline" > video_data/config/status.txt

function ctrl_c() {
        echo "[info] streamrecording stops"
        brokenFile=$(ls -t ${path} | head -n 1)
        n=$(ls ${path}| wc -l )
        if ((n >= 1)); then
            if $_recordFlag; then
                if $_oneFlag;  then
                    _oneFlag=false
                    echo "[info] delete broken record - $brokenFile"
                    rm ${path}/$brokenFile
                fi
            fi
        fi
        echo "offline" > video_data/config/status.txt
        exit 1
}


trap ctrl_c INT
echo "[info] streamrecorder starts"

check=$(ffprobe -v quiet -print_format json -show_streams ${url} -rw_timeout 5000000)

length=$(echo $check | jq '. | length')

if ((length == 0)); then
    echo "[error] no livestream available"
    echo "[info] try again in ${waitAfterError} seconds"
    sleep ${waitAfterError}
    chmod u+x streamRecorder.sh
    ./streamRecorder.sh
else
    result=$(echo "${check}" | jq '.streams | .[].index')
fi


#if ((result == 0)); then
    echo "online" > video_data/config/status.txt
    echo "[info] found livestream"
    echo "[info] starting converter in background"
    _recordFlag=true
    echo "[info] save video files in $folder"
    echo "[info] starting ffmpeg"
    ffmpeg -rw_timeout 1000000 -i ${url} \
        -flags +global_header -f \
        segment -segment_time ${interval} \
        -reset_timestamps 1 -strftime 1 \
        -segment_format mp4 \
        ${path}/stream_%d%m%Y-%H_%M_%S.mp4 -hide_banner


    brokenFile=$(ls -t ${path} | head -n 1)
        n=$(ls ${path}| wc -l )
        echo "[info] delete broken record - $brokenFile"
        rm ${path}/$brokenFile

        fi

    chmod u+x streamRecorder.sh
    ./streamRecorder.sh
#fi



