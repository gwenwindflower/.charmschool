function gh
    op run --env-file=$OP_ENV_DIR/gh.env --no-masking -- gh $argv
end
