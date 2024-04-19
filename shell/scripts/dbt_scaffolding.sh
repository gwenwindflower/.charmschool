#wrapper functions around dbt codegen for scaffolding boiler plate dbt models
function dbtsrc() {
    database_name=$1
    schema_name=$2
    echo 'building source yaml for '"$database_name"''
    mkdir -p ./models/staging/"$schema_name"
    touch ./models/staging/"$schema_name"/_source.yml
    dbt --log-format json \
        run-operation generate_source \
        --args '{"schema_name": '"$schema_name"', "database_name": '"$database_name"'}' |
        jq -r 'select(.message | contains ("version") ) | .message' \
            >./models/staging/"$schema_name"/_source.yml
}

function dbtstg() {
    source_name=$1
    table_name=$2
    echo 'building staging model for '"$table_name"' in source '"$source_name"''
    mkdir -p ./models/staging/"$source_name"
    touch ./models/staging/"$source_name"/stg_"$source_name"_"$table_name".sql
    dbt --log-format json \
        run-operation generate_base_model \
        --args '{"source_name": '"$source_name"', "table_name": '"$table_name"'}' |
        jq -r 'select(.message | startswith ("with") ) | .message' \
            >./models/staging/"$source_name"/stg_"$source_name"_"$table_name".sql
}

function dbtstb() {
    database_name=$1
    schema_name=$2   
    dbtsrc "$database_name" "$schema_name"
    length=$(cat ./models/staging/"$schema_name"/_source.yml | shyaml get-length sources.0.tables)
    length=$((length - 1))
    for i in {0.."$length"}; do
        table_name=$(cat ./models/staging/"$schema_name"/_source.yml | shyaml get-value sources.0.tables."$i".name)
        dbtstg "$schema_name" "$table_name"
    done
}
