#!/usr/bin/bash

# preset exit codes
E_DIR_NOMATCH=50
E_BAD_DBFILE=51


dbfile=Filerec.md5
# storing records.
set_up_database ()
{
    echo ""$directory"" > "$dbfile"
    # Write directory name to first line of file.
    md5sum "$directory"/* >> "$dbfile"
    # Append md5 checksums and filenames.
}
check_database ()
{
    local n=0
    local filename
    local checksum
    if [ ! -r "$dbfile" ]
    then
        echo "Unable to read checksum database file!"
        exit $E_BAD_DBFILE
    fi

    while read rec[n]
    do
        directory_checked="${rec[0]}"
        if [ "$directory_checked" != "$directory" ]
        then
            echo "Directories do not match up!"
            # Tried to use file for a different directory.
            exit $E_DIR_NOMATCH
        fi
        if [ "$n" -gt 0 ]
        then
            filename[n]=$( echo ${rec[$n]} | awk '{ print $2 }' )
            # md5sum writes recs backwards,
            #+ checksum first, then filename.
            checksum[n]=$( md5sum "${filename[n]}" )
            if [ "${rec[n]}" = "${checksum[n]}" ]
            then
                echo "${filename[n]} unchanged."
            else
                echo "${filename[n]} : CHECKSUM ERROR!"
            fi
        fi
        let "n+=1"
        done <"$dbfile" # Read from checksum database file.
}

# checks if argv[1] is empty; if yes, sets current directory to directory 
if [ -z "$1" ]
then
    directory="$PWD" # If not specified,
 else
    directory="$1"
fi

# Below 'if statement' searches history to find record of dbfile
if [ ! -r "$dbfile" ]
then
    echo "Setting up database file, \""$directory"/"$dbfile"\".";
    echo
    set_up_database
fi
check_database
echo
exit 0
