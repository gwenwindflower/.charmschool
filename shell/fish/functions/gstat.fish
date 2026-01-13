function gstat -d "Print one-line summary of git status"
    echo "$(git status --porcelain)" | awk '
    BEGIN { m=0; a=0; d=0; u=0; r=0; c=0 }
    /^M.|^.M/  { m++ }
    /^A.|^.A/  { a++ }
    /^D.|^.D/  { d++ }
    /^R.|^.R/  { r++ }
    /^C.|^.C/  { c++ }
    /^\?\?/    { u++ }
    END { 
        output = ""
        if (m > 0) output = output (output ? ", " : "") m " modified"
        if (a > 0) output = output (output ? ", " : "") a " added"
        if (d > 0) output = output (output ? ", " : "") d " deleted"
        if (u > 0) output = output (output ? ", " : "") u " untracked"
        if (r > 0) output = output (output ? ", " : "") r " renamed"
        if (c > 0) output = output (output ? ", " : "") c " copied"
        if (output == "") output = "ᓬ(ᵕᴗᵕ)ᕒ All clean, good job  !"
        print output
    }'
end
