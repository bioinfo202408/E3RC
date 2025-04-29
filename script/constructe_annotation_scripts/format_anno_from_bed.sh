input_file="$1"
output_file="$2"

printf "chr\tstart\tend\tlength\tabs_summit\n" > "$output_file"

awk -v OFS="\t" '
{
    col1 = $1              
    col2 = $2                 
    col3 = $3                    
    col4 = $3 - $2 + 1               
    print col1, col2, col3, col4
}
' "$input_file" >> "$output_file"