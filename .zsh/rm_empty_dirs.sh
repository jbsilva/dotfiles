# Remove empty directories.
# Requires GNU find
function rm_empty_dirs()
{
    local DIR="${1:-'.'}"
    find ${DIR} -type d -empty -delete
    #find ${DIR} -depth -type d -empty -print0 | xargs -0 rmdir
}
