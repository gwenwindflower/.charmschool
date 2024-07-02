function snoq -d "Query Snowflake via the CLI"
    snow sql --query "$argv[1]" --connection "$argv[2]"
end
