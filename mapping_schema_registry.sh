rm result_mapping_schema.json -rf
get_subject=$(curl -X GET <Url Node schema registry> -k -u "< username >:< password >" | jq . | tr -d "[]" | tr -d '"' | tr -d ',')
get_topic=$(kafka-topics --list --bootstrap-server <list kafka-broker and port>)
array_topic=($get_topic)
array_subject=($get_subject)
json_file="result_mapping_schema.json"  

index=0

for topic in "${array_topic[@]}"; do
  key="not have key"
  value="not have value"
  for element in "${array_subject[@]}"; do
    cleaned_element="${element/-value/}"
    cleaned_element="${cleaned_element/-key/}"
    if [[ "$cleaned_element" == "$topic" ]]; then
      if [[ "$element" == *"-key" ]]; then
        key="$element"
      else
        value="$element"
      fi
    fi
  done

  hasil='{"topic": "'$topic'","key": "'$key'","value": "'$value'"}'
  results+=("$hasil")
  index=$((index + 1))
done

for element in "${array_subject[@]}"; do
  has_topic=false
  cleaned_element="${element/-value/}"
  cleaned_element="${cleaned_element/-key/}"
  for topic in "${array_topic[@]}"; do
    if [[ "$cleaned_element" == "$topic" ]]; then
      has_topic=true
    fi
  done

  if [ "$has_topic" == false ]; then
    if [[ "$element" == *"-value" ]]; then
      value=$element
    else
      value="not have value"
    fi
    if [[ "$element" == *"-key" ]]; then
      key=$element
    else
      key="not have key"
    fi
    result="{\"topic\": \"tidak memiliki topik\", \"key\": \"$key\", \"value\": \"$value\"}"
    results+=("$result")
  fi
done

json_result="["
for result in "${results[@]}"; do
  json_result+=" $result,"
done
json_result="${json_result%,}"
json_result+=" ]"

echo "$json_result" > $json_file
