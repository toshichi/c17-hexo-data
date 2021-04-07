# This script works at hexo root folder
md_path="source/_posts/"
img_old_path="](.images\/"
img_new_path="](\/blogimg\/"

# process all md files
for md in $md_path*.md ; do
    if [ -e "$md" ]; then
        filename="${md##*/}"
        echo "Processing ${filename}..."
        filename_no_ext="${filename%.*}"
        # replace image path prefix in md files
        sed -i "s/${img_old_path}/${img_new_path}/g" "${md}"

    fi
done
# move image files
if [ "$(ls -A ${md_path}.images)" ]; then
    echo "Moving image files"
    mkdir -p source/blogimg
    mv ${md_path}.images/* source/blogimg/
fi
