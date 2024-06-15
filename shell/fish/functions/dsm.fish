function dsm
    if test -z "$argv[3]"
        dbt parse and dbt sl query --metrics $argv[1] --group-by $argv[2] --order-by $argv[2]
    else
        dbt parse and dbt sl query --metrics $argv[1] --group-by $argv[2] --order-by $argv[2] --where $argv[3]
    end
end
