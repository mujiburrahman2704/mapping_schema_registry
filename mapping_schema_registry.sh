rm hasil_mapping_schema.json -rf
get_subject=$(curl -X GET <Url Node schema registry> -k -u "< username >:< password >" | jq . | tr -d "[]" | tr -d '"' | tr -d ',')
get_topic=$(kafka-topics --list --bootstrap-server broker1.muji.com:9095,broker2.muji.com:9095,broker3.muji.com:9095)
array_topic=($get_topic)
array_subject=($get_subject)
json_file="hasil_mapping_schema.json"  

# Inisialisasi indeks
index=0

# Iterasi melalui array topic
for topic in "${array_topic[@]}"; do
  # Inisialisasi variabel key dan value
  key="tidak memiliki key"
  value="tidak memiliki value"
  # Iterasi melalui array utama
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

  # Cetak hasil
  hasil='{"topic": "'$topic'","key": "'$key'","value": "'$value'"}'
  results+=("$hasil")
  index=$((index + 1))
done

for element in "${array_subject[@]}"; do
  echo "ini adalah $element"
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
      value="tidak memiliki value"
    fi
    if [[ "$element" == *"-key" ]]; then
      key=$element
    else
      key="tidak memiliki key"
    fi
    echo "hasil $key $value"
    result="{\"topic\": \"tidak memiliki topik\", \"key\": \"$key\", \"value\": \"$value\"}"
    echo "ini adalah $result"
    results+=("$result")
  fi
done

# Gabungkan hasil ke dalam bentuk JSON array
json_result="["
for result in "${results[@]}"; do
  json_result+=" $result,"
done
json_result="${json_result%,}"  # Hapus koma terakhir
json_result+=" ]"

# Simpan JSON ke dalam file
echo "$json_result" > $json_file
