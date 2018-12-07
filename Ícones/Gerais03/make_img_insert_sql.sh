#!/bin/bash
#https://www.zabbix.com/forum/showthread.php?t=12155
#https://www.zabbix.com/forum/showpost.php?p=44478&postcount=2


### GLOBALS
# 25-10-13 Tobias o ls utilizando essa sintexe gera erro
#IMG_EXT="{png,jpg,gif}"
IMG_EXT="png"
# 25-10-13 Tobias o nome do arquivo sql contem o nome do diretorio
SQL_FILE="my_images_mysql_$(basename $1).sql"
SQL_INS="INSERT INTO images VALUES ("
SQL_IMAGEID_RANGE=0
SQL_IMAGETYPE=1
SQL_NAME=""
SQL_IMAGE=""

### ERROR
NORMAL=0
ERR_ARGS=1
ERR_NO_DIR=2
ERR_NO_FILE=3
RETVAL=$NORMAL

########################################################################
### Actual Main
########################################################################
main() {

    local dir=$1
    local num=$2
    
    # check the number of command argument
    if [ $# -lt 2 ]; then
        return $ERR_ARGS
    fi
    
    # check target dir
    [ ! -d $dir ] && return $ERR_NO_DIR

    # check target file
    check_image_file $dir || return $?

    # make sql file
    make_sql_file $num

    return $RETVAL
}

########################################################################
### Check image files existence
########################################################################
check_image_file() {

    local dir=$1
    local file_num=0

    file_num=$(eval ls $dir/*.$IMG_EXT 2>/dev/null | wc -l)
    [ $file_num -eq 0 ] && return $ERR_NO_FILE

    return $RETVAL
}

########################################################################
### Make SQL file to insert image files
########################################################################
make_sql_file() {
    
    local f=

    [ -f $SQL_FILE ] && rm -f $SQL_FILE
    
    SQL_IMAGEID=$1
    for f in $(eval ls $dir/*.$IMG_EXT 2>/dev/null)
    do
        SQL_NAME=$(basename $f | cut -d. -f1)
	# 25-10-13 Tobias adicionado o nome do diretorio ao nome do arquivo
	SQL_NAME="${SQL_NAME}_$(basename $dir)"
        SQL_IMAGE="0x$(od -tx1 $f | awk '{for(i=2; i<=NF; i++) printf("%s", toupper($i))}')"
        echo "$SQL_INS $SQL_IMAGEID, $SQL_IMAGETYPE, '$SQL_NAME', $SQL_IMAGE);" >> $SQL_FILE
        SQL_IMAGEID=$(($SQL_IMAGEID + 1))
        echo -n "." # in progress 
    done

    echo -e "\ncompleted"
    return $RETVAL
}


########################################################################
### Check error and display error message
########################################################################
check_error() {

    local result=$1

    case $result in
        $ERR_ARGS)
            usage
            ;;
        $ERR_NO_DIR)
            echo "cannot find target dir"
            ;;
        $ERR_NO_FILE)
            echo "cannot find \"*.$IMG_EXT\" files"
            ;;
        *)
            echo "unknown error"
            ;;
    esac

    return $result
}

########################################################################
### Usage
########################################################################
usage() {
    echo "Usage: make_img_insert_sql.sh <dir> <start_imageid>"
}

########################################################################
### Script Main
########################################################################
main "$@" || check_error $?


