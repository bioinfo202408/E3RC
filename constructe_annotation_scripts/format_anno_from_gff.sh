input_file="$1"
output_file="$2"

printf "chr\tstart\tend\tlength\tabs_summit\n" > "$output_file"

awk -v OFS="\t" '
{
    col1 = "chr" $1              
    col2 = $4 - 1                 
    col3 = $5                     
    col4 = $5 - $4                
    print col1, col2, col3, col4
}
' "$input_file" >> "$output_file"

