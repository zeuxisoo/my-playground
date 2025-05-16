#/bin/bash

# list each playground latest commit date in current directory without files

# included sub dirs and files
# for file in $(git ls-files); do
#     echo "$(git log -1 --format="%ci" -- "$file") $file"
# done | sort

# exclude sub dirs and files
for item in $(git ls-tree -d --name-only HEAD); do
    # get latest playground directory commit date, ignore empty not tracked directory and error
    date=$(git log -1 --format="%ci" -- "$item" 2>/dev/null)
    echo "$date $item"
done | sort

