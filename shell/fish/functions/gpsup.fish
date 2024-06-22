function gpsup -d "Push current branch to origin as new branch and set that remote branch as upstream"
    git push --set-upstream origin $(git branch --show-current)
end
