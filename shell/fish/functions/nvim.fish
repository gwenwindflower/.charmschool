function nvim
    op run --env-file=$OP_ENV_DIR/nvim.env --no-masking -- nvim $argv
end
