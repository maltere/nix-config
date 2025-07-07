function ipinfo() {
    curl -s "https://ipinfo.io/$1" | jq .
}

function bgplgext() {
    for prefix in "$@"; do
        curl_command="curl -s --location --request GET \"https://stat.ripe.net/data/looking-glass/data.json?resource=$prefix\""
        echo "Curl Command: $curl_command"

        response=$(eval "$curl_command" | jq -r '.data.rrcs[].peers[].as_path')

        advertisedByCustomer=$(echo "$response" | grep -v 13335 | wc -l)
        advertisedByCF=$(echo "$response" | grep 13335 | wc -l | perl -pe 's/^ *//')

        upstreamcount=$(echo "$response" | perl -pe 's/.*?(\d+\s\d+)$/$1/g' | perl -pe 's/.*?13335/13335/g' | sort | uniq -c | perl -pe 's/(\d+)\s+(\d+)/$1\t$2/')

        printf "\n------------------\nPrefix: %s\nCF: %d\nNon-CF: %d\nCount\tAS Path\n%s\n" "$prefix" "$advertisedByCF" "$advertisedByCustomer" "$upstreamcount"
    done
}

function cfnewrelease() {
    git fetch --prune-tags -f origin
    git pull --rebase
    set NEXT_TAG (cfsetup release next-tag)
    echo "Releasing version $NEXT_TAG..."

    git checkout -b "releases/$NEXT_TAG"
    or exit 1

    cfsetup release update -C
    or exit 1

    git push --tags
    git push --set-upstream origin "releases/$NEXT_TAG"
}