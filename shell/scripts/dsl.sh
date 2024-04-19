#!/bin/sh

function dsl() {
  echo '{{Color "44" "dsl"}}' '{{ Italic "a tiny tool for dbt queries"}}' | gum format -t template
  TYPE=$(gum choose "metrics" "saved-query" "export")
  if [ "$TYPE" = "metrics" ]; then
    METRICS=($(cat ./target/semantic_manifest.json | jq -r '.metrics[].name'))
    CHOICE=$(gum choose ${METRICS})
    TIME=$(gum choose "day" "week" "month" "quarter" "year")
    PE=()

    while IFS= read -r line; do
        PE+=("$line")
    done < <(cat ./target/semantic_manifest.json | jq -r '.semantic_models[].entities[] | select(.type == "primary") | .name')

    DIMS=()
    for entity in "${PE[@]}"; do
        dimensions=$(cat ./target/semantic_manifest.json | jq -r --arg entity "$entity" '.semantic_models[] | select(.entities[] | select(.name == $entity and .type == "primary")) | .dimensions[].name')

        while IFS= read -r dim; do
            DIMS+="${entity}__${dim}"
        done <<< "$dimensions"
    done
    if $(gum confirm "Pick a group-by dimension?"); then
      DIM=$(gum filter ${DIMS[@]})
      dbt sl query --metrics ${CHOICE} --group-by "metric_time__${TIME}",${DIM} --order-by "metric_time__${TIME}"
    else
      echo "$GROUP"
      dbt sl query --metrics ${CHOICE} --group-by "metric_time__${TIME}" --order-by "metric_time__${TIME}"
    fi
  else
    SQ=($(cat ./target/semantic_manifest.json | jq -r '.saved_queries[].name'))
    CHOICE=$(gum choose ${SQ})
    if [ $TYPE = "export" ]; then
      dbt sl export --saved-query ${CHOICE}
    elif [ $TYPE = "saved-query" ]; then
      dbt sl query --saved-query ${CHOICE}
    else
      echo "Invalid choice"
    fi
  fi
}
