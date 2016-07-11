getuti()
{
    local usage="$(
cat <<EOF
Usage:
        $0 [EXT]        Gets the UTI (Universal Type Identifier) of extension.

Examples:
        $ getuti txt
        kMDItemContentTypeTree = (
            "public.plain-text",
            "public.text",
            "public.data",
            "public.item",
            "public.content"
        )

        $ getuti document.doc
        kMDItemContentTypeTree = (
            "com.microsoft.word.doc",
            "public.data",
            "public.item"
        )

Report bugs to <julio@juliobs.com>.
EOF
    )"

    if (( $# == 1 )); then
        local f="/tmp/getuti.${1##*.}"
        touch "$f"
        mdimport "$f"
        mdls -name kMDItemContentTypeTree "$f"
        rm -f "$f"
    else
      print "$usage" >&2
      return 1
    fi
}
