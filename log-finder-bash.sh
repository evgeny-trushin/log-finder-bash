#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Check if search pattern argument is provided
if [[ $# -eq 0 ]]; then
    echo -e "${RED}❌ Error: Please provide a search pattern${NC}" >&2
    echo -e "${YELLOW}Usage: $0 <pattern>${NC}" >&2
    echo -e "${BLUE}Example: $0 '*.log'${NC}" >&2
    echo -e "${BLUE}Note: Searches both files and directories${NC}" >&2
    exit 1
fi

SEARCH_PATTERN="$1"
OUTPUT_FILE="$HOME/search_results.txt"
BACKUP_FILE="${OUTPUT_FILE}.tmp"

echo -e "${CYAN}🔧 Setting up output file for append mode...${NC}" >&2
echo -e "${BLUE}   Results will be appended to: ${WHITE}${OUTPUT_FILE}${NC}" >&2
if [[ -f "$OUTPUT_FILE" ]]; then
    echo -e "${GREEN}   ✅ Existing results file found, will append new results${NC}" >&2
else
    echo -e "${BLUE}   ℹ️  No previous results file found, will create new file${NC}" >&2
fi
echo -e "${GREEN}✅ Output file setup complete${NC}" >&2

echo -e "${PURPLE}🔍 Configuring search pattern...${NC}" >&2
echo -e "${BLUE}   Searching for files and directories matching: ${WHITE}${SEARCH_PATTERN}${NC}" >&2
patterns=(
    -iname "${SEARCH_PATTERN}"
)
echo -e "${GREEN}✅ Search pattern configured successfully${NC}" >&2

echo -e "${CYAN}📂 Configuring search directories...${NC}" >&2
echo -e "${BLUE}   Base directories: /etc, /var, /tmp, $HOME${NC}" >&2
search_dirs=(
    "/etc"
    "/var"
    "/tmp"
    "$HOME"
)
echo -e "${GREEN}✅ Base search directories configured${NC}" >&2

echo -e "${YELLOW}🖥️  Directory configuration complete${NC}" >&2

echo -e "\n${BOLD}${WHITE}🚀 Starting files and directories search for pattern: ${YELLOW}${SEARCH_PATTERN}${NC}" >&2
total_dirs=${#search_dirs[@]}
current_dir=0

for dir in "${search_dirs[@]}"; do
    ((current_dir++))
    echo -e "${BOLD}${CYAN}[$current_dir/$total_dirs]${NC} ${WHITE}Searching in:${NC} ${YELLOW}$dir${NC}" >&2
    
    if [[ ! -d "$dir" ]]; then
        echo -e "${RED}  ⚠️  Skipping (directory not found)${NC}" >&2
        continue
    fi

    echo -e "${BLUE}  ⚙️  Configuring search options for directory...${NC}" >&2
    extra_opts=()
    if [[ "$dir" == "/etc" ]]; then
        echo -e "${YELLOW}  🔒 Applying special permissions filter for /etc directory${NC}" >&2
        extra_opts+=(-readable ! -user root)
    else
        echo -e "${BLUE}  📋 Using standard search options${NC}" >&2
    fi

    echo -e "${PURPLE}  🔍 Executing find command with depth limit 3...${NC}" >&2
    find "$dir" \
        -maxdepth 3 \
        \( -type f -o -type d \) \
        -mount \
        "${extra_opts[@]}" \
        \( "${patterns[@]}" \) \
        -print 2>/dev/null
    echo -e "${GREEN}  ✅ Search completed for this directory${NC}" >&2
done >> "$OUTPUT_FILE"

echo -e "\n${CYAN}📊 Processing and deduplicating results...${NC}" >&2
echo -e "${BLUE}💾 Appending results to $OUTPUT_FILE...${NC}" >&2

# Sort and deduplicate the file in place
sort -u "$OUTPUT_FILE" -o "$OUTPUT_FILE"

file_count=$(wc -l < "$OUTPUT_FILE")
new_matches=$(grep -c "${SEARCH_PATTERN//\*/.*}" "$OUTPUT_FILE" 2>/dev/null || echo "0")
echo -e "${GREEN}✅ Results processed successfully${NC}" >&2
echo -e "\n${BOLD}${GREEN}🎉 Search complete! Total files in results: ${WHITE}$file_count${GREEN}${NC}" >&2
echo -e "${CYAN}📁 Results appended to: ${YELLOW}$OUTPUT_FILE${NC}" >&2